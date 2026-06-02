#!/usr/bin/env bash

# Evitar la ejecución si ocurre cualquier error menor y asegurar tuberías limpias
set -euo pipefail

# Definición de colores para logs legibles y estéticos
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0;0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[ÉXITO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[ADVERTENCIA]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# 1. Definir prefijo de instalación
PREFIX=""
if [ "$EUID" -eq 0 ]; then
    PREFIX="/usr"
    log_info "Ejecutando como root. Instalación global en: $PREFIX"
else
    PREFIX="$HOME/.local"
    log_info "Ejecutando como usuario normal. Instalación local en: $PREFIX"
fi

# 2. Verificar e instalar dependencias
log_info "Verificando dependencias del sistema..."

DEPENDENCIAS_BINARIAS=("cmake" "pkg-config" "g++" "moc")
DEPENDENCIAS_FALTANTES=()

for dep in "${DEPENDENCIAS_BINARIAS[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        # moc podría estar en /usr/lib/qt6/moc o similar, verificar rutas comunes
        if [ "$dep" = "moc" ] && [ -x "/usr/lib/qt6/moc" ]; then
            continue
        fi
        DEPENDENCIAS_FALTANTES+=("$dep")
    fi
done

# Verificar archivos de desarrollo específicos usando pkg-config
QT6_MODS=("Qt6Core" "Qt6Multimedia" "Qt6DBus" "Qt6Quick")
for mod in "${QT6_MODS[@]}"; do
    if ! pkg-config --exists "$mod" &> /dev/null; then
        DEPENDENCIAS_FALTANTES+=("$mod-dev")
    fi
done

# Verificar Extra CMake Modules (ECM)
if ! cmake --find-package -DNAME=ECM -DCOMPILER_ID=GNU -DLANGUAGE=CXX -DMODE=EXIST &> /dev/null; then
    DEPENDENCIAS_FALTANTES+=("extra-cmake-modules")
fi

if [ ${#DEPENDENCIAS_FALTANTES[@]} -ne 0 ]; then
    log_warning "Faltan dependencias: ${DEPENDENCIAS_FALTANTES[*]}"
    
    # Intentar instalar dependencias automáticamente según el gestor de paquetes
    if command -v apt-get &> /dev/null; then
        log_info "Detectado gestor de paquetes APT (Debian/Ubuntu/KDE Neon). Instalando dependencias..."
        
        # Mapear nombres a paquetes de apt
        APT_PAQS=()
        for dep in "${DEPENDENCIAS_FALTANTES[@]}"; do
            case "$dep" in
                "cmake") APT_PAQS+=("cmake") ;;
                "pkg-config") APT_PAQS+=("pkg-config") ;;
                "g++") APT_PAQS+=("build-essential") ;;
                "moc") APT_PAQS+=("qt6-base-dev-tools") ;;
                "Qt6Core-dev"|"Qt6DBus-dev"|"Qt6Quick-dev") APT_PAQS+=("qt6-base-dev") ;;
                "Qt6Multimedia-dev") APT_PAQS+=("qt6-multimedia-dev") ;;
                "extra-cmake-modules") APT_PAQS+=("extra-cmake-modules") ;;
            esac
        done
        
        # Eliminar duplicados
        APT_PAQS=($(echo "${APT_PAQS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
        
        log_info "Ejecutando: sudo apt-get update && sudo apt-get install -y ${APT_PAQS[*]}"
        if ! sudo apt-get update && sudo apt-get install -y "${APT_PAQS[@]}"; then
            log_error "Error al instalar las dependencias mediante APT. Por favor, instálalas manualmente."
            exit 1
        fi
    elif command -v pacman &> /dev/null; then
        log_info "Detectado gestor de paquetes pacman (Arch Linux). Instalando dependencias..."
        
        PACMAN_PAQS=()
        for dep in "${DEPENDENCIAS_FALTANTES[@]}"; do
            case "$dep" in
                "cmake") PACMAN_PAQS+=("cmake") ;;
                "pkg-config") PACMAN_PAQS+=("pkgconf") ;;
                "g++") PACMAN_PAQS+=("gcc") ;;
                "moc"|"Qt6Core-dev"|"Qt6DBus-dev"|"Qt6Quick-dev") PACMAN_PAQS+=("qt6-base") ;;
                "Qt6Multimedia-dev") PACMAN_PAQS+=("qt6-multimedia") ;;
                "extra-cmake-modules") PACMAN_PAQS+=("extra-cmake-modules") ;;
            esac
        done
        
        PACMAN_PAQS=($(echo "${PACMAN_PAQS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))
        
        log_info "Ejecutando: sudo pacman -Sy --noconfirm ${PACMAN_PAQS[*]}"
        if ! sudo pacman -Sy --noconfirm "${PACMAN_PAQS[@]}"; then
            log_error "Error al instalar las dependencias mediante pacman. Por favor, instálalas manualmente."
            exit 1
        fi
    else
        log_error "No se pudo identificar un gestor de paquetes compatible para instalar automáticamente: ${DEPENDENCIAS_FALTANTES[*]}."
        log_error "Por favor, instale estas herramientas manualmente antes de continuar."
        exit 1
    fi
else
    log_success "Todas las dependencias están resueltas."
fi

# 3. Compilación limpia y segura
log_info "Iniciando proceso de compilación..."

# Asegurar que el directorio build esté completamente limpio antes de empezar
if [ -d "build" ]; then
    log_info "Limpiando directorio build existente..."
    rm -rf build
fi

mkdir build
cd build

log_info "Configurando CMake con prefijo $PREFIX..."
if ! cmake -DCMAKE_INSTALL_PREFIX="$PREFIX" -DCMAKE_BUILD_TYPE=Release ..; then
    log_error "Fallo en la configuración del proyecto mediante CMake."
    # Limpiar antes de salir en caso de fallo
    cd .. && rm -rf build
    exit 1
fi

log_info "Compilando código fuente..."
if ! make -j"$(nproc)"; then
    log_error "Fallo durante la compilación (make)."
    cd .. && rm -rf build
    exit 1
fi

log_info "Instalando archivos al sistema..."
if [ "$PREFIX" = "/usr" ]; then
    if ! sudo make install; then
        log_error "Fallo al instalar usando sudo make install."
        cd .. && rm -rf build
        exit 1
    fi
else
    if ! make install; then
        log_error "Fallo al instalar usando make install local."
        cd .. && rm -rf build
        exit 1
    fi
fi

# 4. Limpieza estricta de archivos huérfanos y de compilación
cd ..
log_info "Eliminando archivos temporales de compilación para no dejar residuos..."
rm -rf build

log_success "¡Raven Wallpaper Engine se ha instalado correctamente de forma limpia!, Archivos huerfanos eliminados..."
log_info "Puedes seleccionarlo ahora en la configuración de fondo de pantalla de KDE Plasma. ¡Huelum!"
