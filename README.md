# 🦅 Raven Wallpaper Engine

![C++20](https://img.shields.io/badge/C%2B%2B-20-blue?logo=c%2B%2B)
![QML](https://img.shields.io/badge/QML-Qt6-41CD52?logo=qt)
![CMake](https://img.shields.io/badge/CMake-3.20+-064F8C?logo=cmake)
![KDE Plasma](https://img.shields.io/badge/KDE_Plasma-6+-1D99F3?logo=kde)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
![Architecture](https://img.shields.io/badge/Architecture-Hexagonal-orange)
![Debian](https://img.shields.io/badge/Debian-D70A53?logo=debian&logoColor=white)
![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?logo=arch-linux&logoColor=white)

Raven Wallpaper Engine es un motor de fondos de pantalla de video de alto rendimiento con aceleración por hardware y copia cero (Zero-Copy) para entornos de escritorio **KDE Plasma 6+**. Está diseñado para ser extremadamente eficiente en el consumo de recursos de CPU y GPU, suspendiendo la reproducción automáticamente cuando no es visible o cuando se detectan estados de ahorro de energía.

## 🚀 Características principales

- **Copia Cero (Zero-Copy):** Renderizado directo y eficiente del flujo de video mediante RHI en QtQuick.
- **Cortocircuito de seguridad (Safety Circuit Breaker):** Control de errores incorporado en C++ para evitar bloqueos y bucles infinitos si un archivo de video se corrompe o no es válido.
- **Suspensión Inteligente (Smart Suspension):** Escucha eventos de D-Bus para pausar automáticamente la reproducción cuando:
  - El sistema entra en modo de suspensión o hibernación.
  - La pantalla se bloquea o el salvapantallas se activa.
  - El modo de ahorro de energía está habilitado (ej. batería baja).
- **Interfaz de Configuración:** Interfaz integrada nativamente con soporte multiidioma automático (detecta el idioma del sistema y muestra la UI en español por defecto, o inglés si el sistema está configurado en otro idioma).
- **Controles avanzados:** Ajustes de volumen (silenciado por defecto), velocidad de reproducción (0.5x - 2.0x), modos de escalado (Estirar, Ajustar, Recortar) y superposición de viñeta para mejorar el contraste.

## 📐 Arquitectura Hexagonal (Ports and Adapters)

El código fuente (C++) de este motor está estrictamente organizado siguiendo el patrón de Arquitectura Hexagonal para garantizar una alta mantenibilidad y desacoplamiento del framework Qt:
- **Dominio (`src/domain`):** Contiene la lógica pura de negocio (`VideoPlaybackService`), que maneja el estado de suspensión, listas de reproducción, modos de bucle y la orquestación, sin acoplarse directamente a reproductores multimedia específicos ni al sistema operativo.
- **Puertos (`src/ports`):** Interfaces abstractas (`IVideoPlayerPort`, `ISystemStatePort`) que dictan qué funcionalidades necesita la lógica de negocio del mundo exterior.
- **Adaptadores (`src/adapters`):**
  - **Multimedia (`QtVideoPlayerAdapter`):** Implementa la reproducción de vídeo conectando el motor subyacente con `QMediaPlayer` de QtMultimedia.
  - **D-Bus (`DBusSystemStateAdapter`):** Escucha pasivamente el bus del sistema (DBus) para interceptar eventos de logind o el salvapantallas.
  - **QML / Interfaz (`QmlVideoController`):** El adaptador primario que expone todas las propiedades y slots de control hacia el entorno gráfico de QML.

## 📊 Consumo de Recursos y Monitoreo (RAM, CPU, GPU)

El rendimiento es una prioridad central en Raven Wallpaper Engine. Al utilizar la API RHI (Rendering Hardware Interface) en modo **Zero-Copy**, el plugin apenas incrementa la huella en la memoria RAM del sistema.
- **Memoria RAM (Sistema):** El plugin en sí mismo solo requiere de **~20 MB a 50 MB adicionales** gestionados dentro del proceso `plasmashell`.
- **Memoria de Vídeo (VRAM):** La decodificación recae principalmente sobre la GPU.

Puedes utilizar las siguientes herramientas para verificar el rendimiento en tu sistema:
- **`btop` o `htop`:** Ejecuta `htop` o `btop` y busca el proceso `plasmashell` para visualizar el consumo de CPU general. Al estar altamente optimizado y utilizar decodificación por hardware, el uso de CPU debería mantenerse mínimo (típicamente por debajo del 2-5% en reposo, variando solo por `plasmashell`).
- **`nvtop`:** Ejecuta `nvtop` en la terminal para observar cómo tu tarjeta gráfica (NVIDIA, AMD o Intel) realiza la decodificación por hardware de los frames del vídeo sin saturar la RAM principal.

## 📦 Requisitos de dependencias

El instalador verificará de forma automática y descargará/compilará las dependencias necesarias de las siguientes herramientas:
- **KDE Plasma 6**
- **CMake** (v3.20 o superior)
- **Extra CMake Modules** (ECM)
- **Qt6Multimedia**, **Qt6Quick** y **Qt6DBus**
- Compilador de C++ compatible con **C++20**

## ⚡ Instalación rápida

Para realizar una instalación limpia, compilar el plugin de QML en C++ y registrar el fondo de pantalla en el sistema para el usuario actual, ejecute el script `install.sh`:

```bash
chmod +x install.sh
./install.sh
```

El instalador se encargará de realizar las comprobaciones, compilar e instalar sin dejar archivos temporales de compilación huérfanos.

## 🧹 Desinstalación

Para remover completamente el motor de fondos de pantalla sin dejar rastro en el sistema, ejecute:

```bash
chmod +x uninstall.sh
./uninstall.sh
```

## 📜 Licencia

Este proyecto está bajo la Licencia Pública General de GNU v3 (GNU GPL v3). Consulte el archivo [LICENSE](./LICENSE) para obtener más información.

## ⚠️ Descargo de Responsabilidad (Disclaimer)

Este software se proporciona "tal cual" (as-is), sin garantía de ningún tipo, expresa o implícita. El uso de este motor de fondos de pantalla es bajo tu propio riesgo. El autor y los contribuyentes no asumen ninguna responsabilidad por cualquier daño al equipo, pérdida de datos, problemas de rendimiento o inestabilidad del entorno de escritorio que puedan resultar de la instalación o uso de este plugin. Al instalar y utilizar este software, aceptas expresamente asumir todos los riesgos derivados de su uso.

### 👨‍💻 Desarrollado por:

Alejandro González Hernández (Vidruck)

## ¡Disfruta de tus fondos de pantalla dinámicos!
