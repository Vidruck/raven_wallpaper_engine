#!/usr/bin/env bash

# Evitar la ejecución si ocurre cualquier error menor y asegurar tuberías limpias
set -euo pipefail

# Colores para la salida en consola
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0;0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[ÉXITO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# 1. Determinar el usuario real y su directorio home (incluso si se ejecuta con sudo)
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

log_info "Usuario detectado: $REAL_USER (Home: $REAL_HOME)"

PATHS_TO_REMOVE=(
    # Rutas locales del usuario
    "$REAL_HOME/.local/share/plasma/wallpapers/org.kde.plasma.ravenwallpaper"
    "$REAL_HOME/.local/lib/qml/org/kde/plasma/ravenwallpaper"
    "$REAL_HOME/.local/lib64/qml/org/kde/plasma/ravenwallpaper"
)

GLOBAL_PATHS_TO_REMOVE=(
    # Rutas globales del sistema
    "/usr/share/plasma/wallpapers/org.kde.plasma.ravenwallpaper"
    "/usr/lib/qml/org/kde/plasma/ravenwallpaper"
    "/usr/lib64/qml/org/kde/plasma/ravenwallpaper"
    "/usr/lib/qt6/qml/org/kde/plasma/ravenwallpaper"
    "/usr/lib/x86_64-linux-gnu/qt6/qml/org/kde/plasma/ravenwallpaper"
    "/usr/lib/qt/qml/org/kde/plasma/ravenwallpaper"
    "/usr/lib/x86_64-linux-gnu/qt/qml/org/kde/plasma/ravenwallpaper"
)

# 2. Remover archivos locales
log_info "Buscando e identificando archivos locales instalados..."
REMOVED_ANY=false

for path in "${PATHS_TO_REMOVE[@]}"; do
    if [ -d "$path" ] || [ -f "$path" ]; then
        log_info "Eliminando archivo/directorio local: $path"
        rm -rf "$path"
        REMOVED_ANY=true
    fi
done

# 3. Remover archivos globales (requiere privilegios root si existen)
log_info "Buscando e identificando archivos globales en el sistema..."
HAS_GLOBAL=false

for path in "${GLOBAL_PATHS_TO_REMOVE[@]}"; do
    if [ -d "$path" ] || [ -f "$path" ]; then
        HAS_GLOBAL=true
        if [ "$EUID" -eq 0 ]; then
            log_info "Eliminando archivo/directorio global (como root): $path"
            rm -rf "$path"
            REMOVED_ANY=true
        else
            log_info "Se detectaron archivos globales en: $path. Intentando eliminar con sudo..."
            if sudo rm -rf "$path"; then
                log_info "Eliminado exitosamente: $path"
                REMOVED_ANY=true
            else
                log_error "No se pudo eliminar el archivo global: $path. Intente ejecutar el script con sudo."
                exit 1
            fi
        fi
    fi
done

# 4. Restablecer el fondo de pantalla por defecto de Plasma para evitar pantallas negras al desinstalar
CONFIG_FILE="$REAL_HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
if [ -f "$CONFIG_FILE" ]; then
    if grep -q "wallpaperplugin=org.kde.plasma.ravenwallpaper" "$CONFIG_FILE"; then
        log_info "Restableciendo el plugin de fondo de pantalla por defecto (org.kde.image) para evitar pantallas negras..."
        # Crear respaldo
        cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"
        if [ "$EUID" -eq 0 ] && [ "$REAL_USER" != "root" ]; then
            chown "$REAL_USER:$REAL_USER" "${CONFIG_FILE}.bak"
        fi
        # Reemplazar el plugin
        sed -i 's/wallpaperplugin=org.kde.plasma.ravenwallpaper/wallpaperplugin=org.kde.image/g' "$CONFIG_FILE"
        if [ "$EUID" -eq 0 ] && [ "$REAL_USER" != "root" ]; then
            chown "$REAL_USER:$REAL_USER" "$CONFIG_FILE"
        fi
        log_success "Configuración de fondo de pantalla restablecida a org.kde.image."
    fi
fi

# 5. Limpieza del directorio local de compilación por si acaso
if [ -d "build" ]; then
    log_info "Eliminando carpeta temporal de compilación 'build' del espacio de trabajo..."
    rm -rf build
fi

# Eliminar archivo de moc generado si quedó
if [ -f "moc_videocontroller.cpp" ]; then
    rm -f moc_videocontroller.cpp
fi

if [ "$REMOVED_ANY" = true ]; then
    log_success "¡Raven Wallpaper Engine se ha desinstalado completamente! ¡Huelum!"
else
    log_info "No se encontraron rastros instalados de Raven Wallpaper Engine en los directorios especificados."
fi
