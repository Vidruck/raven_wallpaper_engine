import QtQuick
import QtMultimedia
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import "imports/org/kde/plasma/ravenwallpaper"

WallpaperItem {
    id: root
    anchors.fill: parent

    // Propiedades de configuración (exposed by Plasma wallpaper system)
    readonly property string videoSource: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.VideoSource : ""
    readonly property color fallbackColor: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.FallbackColor : "#121214"
    readonly property double videoVolume: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.Volume : 0.0
    readonly property double playbackRate: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.PlaybackRate : 1.0
    readonly property int fillModeIndex: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.FillMode : 2
    readonly property bool showOverlay: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.ShowOverlay : false
    readonly property int sourceType: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.SourceType : 0
    readonly property bool mute: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.Mute : true
    readonly property int loopMode: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.LoopMode : 0
    readonly property int playlistOrder: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.PlaylistOrder : 0

    // Fondo alternativo de seguridad (fallback background)
    Rectangle {
        id: fallbackBg
        anchors.fill: parent
        color: root.fallbackColor

        // Degradado para diseño premium (premium styling)
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.lighter(root.fallbackColor, 1.1) }
            GradientStop { position: 1.0; color: Qt.darker(root.fallbackColor, 0.9) }
        }
    }

    // Controlador de video personalizado (custom video controller)
    VideoController {
        id: controller
        source: root.videoSource
        sourceType: root.sourceType
        loopMode: root.loopMode
        playlistOrder: root.playlistOrder
        mute: root.mute
        volume: root.videoVolume
        playbackRate: root.playbackRate
    }

    // Salida de video renderizada con copia cero (zero-copy)
    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        
        // Mapea el índice de configuración al enum (fill mode)
        fillMode: {
            if (root.fillModeIndex === 0) return VideoOutput.Stretch;
            if (root.fillModeIndex === 1) return VideoOutput.PreserveAspectFit;
            return VideoOutput.PreserveAspectCrop;
        }
        
        // Ocultar al haber errores o suspensión para no consumir recursos (rendering)
        visible: !controller.hasError && !controller.isSuspended && root.videoSource !== ""
        
        // Enlazar el reproductor multimedia (media player) a este visualizador
        // Mensajes de diagnóstico (diagnostics) al montar y desmontar el componente
        Component.onCompleted: {
            console.log("RavenWallpaper: VideoOutput completed. Sink:", videoOutput.videoSink);
            console.log("RavenWallpaper: mediaPlayer:", controller.mediaPlayer);
            controller.mediaPlayer.videoOutput = videoOutput.videoSink
            console.log("RavenWallpaper: videoSource =", root.videoSource);
            console.log("RavenWallpaper: visible =", visible);
            console.log("RavenWallpaper: isSuspended =", controller.isSuspended);
            console.log("RavenWallpaper: hasError =", controller.hasError);
        }

        Connections {
            target: controller.mediaPlayer
            function onPlaybackStateChanged() {
                console.log("RavenWallpaper: Playback state changed to", controller.mediaPlayer.playbackState);
            }
            function onMediaStatusChanged() {
                console.log("RavenWallpaper: Media status changed to", controller.mediaPlayer.mediaStatus);
            }
            function onErrorOccurred(error, errorString) {
                console.log("RavenWallpaper: MediaPlayer ERROR:", error, errorString);
            }
        }

        // Animaciones para transiciones fluidas (smooth transitions)
        opacity: visible ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
        }
    }

    // Superposición oscura para contraste (overlay vignette)
    Rectangle {
        id: premiumOverlay
        anchors.fill: parent
        visible: root.showOverlay
        color: "transparent"
        opacity: videoOutput.opacity

        // Degradado radial simulado (radial gradient) para efecto viñeta
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1a000000" } // 10% opacity center
            GradientStop { position: 0.5; color: "#66000000" } // 40% opacity mid
            GradientStop { position: 1.0; color: "#cc000000" } // 80% opacity edge
        }

        Behavior on opacity {
            NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
        }
    }
}
