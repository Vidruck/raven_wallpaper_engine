cmake_minimum_required(VERSION 3.20)

project(raven_wallpaper_engine LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(QT_VERSION_MAJOR 6)
find_package(Qt6 COMPONENTS Core Quick Multimedia DBus REQUIRED)

find_package(ECM REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

# QML Module configuration
qt_add_qml_module(ravenwallpaperplugin
    URI "org.kde.plasma.ravenwallpaper"
    VERSION 1.0
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/org/kde/plasma/ravenwallpaper
    SOURCES
        src/ports/IVideoPlayerPort.h
        src/ports/ISystemStatePort.h
        src/domain/VideoPlaybackService.h
        src/domain/VideoPlaybackService.cpp
        src/adapters/multimedia/QtVideoPlayerAdapter.h
        src/adapters/multimedia/QtVideoPlayerAdapter.cpp
        src/adapters/dbus/DBusSystemStateAdapter.h
        src/adapters/dbus/DBusSystemStateAdapter.cpp
        src/adapters/qml/QmlVideoController.h
        src/adapters/qml/QmlVideoController.cpp
)

target_link_libraries(ravenwallpaperplugin
    PRIVATE
        Qt6::Core
        Qt6::Quick
        Qt6::Multimedia
        Qt6::DBus
)

target_include_directories(ravenwallpaperplugin
    PRIVATE
        src
        src/ports
        src/domain
        src/adapters/multimedia
        src/adapters/dbus
        src/adapters/qml
)

set_target_properties(ravenwallpaperplugin PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/org/kde/plasma/ravenwallpaper
)

set_target_properties(ravenwallpaperpluginplugin PROPERTIES
    PREFIX "lib"
    BUILD_RPATH "$ORIGIN"
    INSTALL_RPATH "$ORIGIN"
)

install(DIRECTORY ${CMAKE_BINARY_DIR}/org/kde/plasma/ravenwallpaper/
    DESTINATION ${KDE_INSTALL_DATADIR}/plasma/wallpapers/org.kde.plasma.ravenwallpaper/contents/ui/imports/org/kde/plasma/ravenwallpaper
    FILES_MATCHING
    PATTERN "*.so"
    PATTERN "qmldir"
    PATTERN "*.qmltypes"
)

# Install metadata.json and packages
install(FILES metadata.json DESTINATION ${KDE_INSTALL_DATADIR}/plasma/wallpapers/org.kde.plasma.ravenwallpaper)
install(DIRECTORY package/contents DESTINATION ${KDE_INSTALL_DATADIR}/plasma/wallpapers/org.kde.plasma.ravenwallpaper)
