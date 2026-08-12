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
    readonly property double vignetteSaturation: (typeof wallpaper !== 'undefined' && wallpaper.configuration.VignetteSaturation !== undefined) ? wallpaper.configuration.VignetteSaturation : 0.5
    readonly property double videoSaturation: (typeof wallpaper !== 'undefined' && wallpaper.configuration.VideoSaturation !== undefined) ? wallpaper.configuration.VideoSaturation : 1.0
    readonly property double videoContrast: (typeof wallpaper !== 'undefined' && wallpaper.configuration.VideoContrast !== undefined) ? wallpaper.configuration.VideoContrast : 1.0
    readonly property int sourceType: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.SourceType : 0
    readonly property bool mute: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.Mute : true
    readonly property int loopMode: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.LoopMode : 0
    readonly property int playlistOrder: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.PlaylistOrder : 0
    readonly property bool showFrame: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.ShowFrame : false
    readonly property int frameThickness: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.FrameThickness : 8
    readonly property int frameRadius: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.FrameRadius : 16
    readonly property color frameColor: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.FrameColor : "#80ffffff"

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

    // Capa de mejora de calidad de imagen (Saturación de Color y Contraste mediante Shader/Mezcla)
    Item {
        id: colorAdjustmentLayer
        anchors.fill: parent
        visible: videoOutput.visible && (root.videoSaturation !== 1.0 || root.videoContrast !== 1.0)
        opacity: videoOutput.opacity

        // Capa de ajuste de contraste (overlay de mezcla de brillo/oscuridad)
        Rectangle {
            anchors.fill: parent
            visible: root.videoContrast !== 1.0
            color: root.videoContrast > 1.0 ? "#ffffff" : "#000000"
            opacity: Math.min(Math.abs(root.videoContrast - 1.0) * 0.35, 0.6)
        }

        // Capa de ajuste de saturación de color (tinte reactivo)
        Rectangle {
            anchors.fill: parent
            visible: root.videoSaturation !== 1.0
            color: root.videoSaturation < 1.0 ? "#808080" : "transparent"
            opacity: root.videoSaturation < 1.0 ? Math.min((1.0 - root.videoSaturation), 0.9) : 0.0
        }
    }

    // Superposición oscura para contraste (overlay vignette con grado de saturación configurable)
    Rectangle {
        id: premiumOverlay
        anchors.fill: parent
        visible: root.showOverlay
        color: "transparent"
        opacity: videoOutput.opacity * Math.max(0.1, root.vignetteSaturation * 1.5)

        // Degradado radial simulado (radial gradient) para efecto viñeta
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.1 * root.vignetteSaturation * 2.0) }
            GradientStop { position: 0.5; color: Qt.rgba(0, 0, 0, 0.4 * root.vignetteSaturation * 2.0) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.85 * root.vignetteSaturation * 2.0) }
        }

        Behavior on opacity {
            NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }
        }
    }

    // Marco redondeado decorativo (Rounded frame overlay con esquinas rellenas)
    Rectangle {
        id: roundedFrame
        visible: root.showFrame
        color: "transparent"

        // Calculamos la extensión necesaria para cubrir completamente las esquinas de la pantalla
        readonly property int d: root.frameThickness + root.frameRadius

        anchors.fill: parent
        anchors.margins: -d

        border.color: root.frameColor
        border.width: root.frameThickness + d
        radius: root.frameRadius + (root.frameThickness + d)
    }
}
