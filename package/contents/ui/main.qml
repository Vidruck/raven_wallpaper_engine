import QtQuick
import QtMultimedia
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import "imports/org/kde/plasma/ravenwallpaper"

WallpaperItem {
    id: root
    anchors.fill: parent
    // Recortar geometría que sobresalga (como los márgenes negativos de roundedFrame)
    // para evitar ensuciar nodos fuera de los límites del monitor en QSGRenderThread.
    clip: true

    // Propiedades de configuración (expuestas por el sistema de fondos de KDE Plasma)
    readonly property string videoSource: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.VideoSource : ""
    readonly property color fallbackColor: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.FallbackColor : "#121214"
    readonly property double videoVolume: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.Volume : 0.0
    readonly property double playbackRate: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.PlaybackRate : 1.0
    readonly property int fillModeIndex: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.FillMode : 2
    readonly property bool showOverlay: (typeof wallpaper !== 'undefined') ? wallpaper.configuration.ShowOverlay : false
    readonly property double vignetteSaturation: (typeof wallpaper !== 'undefined' && wallpaper.configuration.VignetteSaturation !== undefined) ? wallpaper.configuration.VignetteSaturation : 0.5
    readonly property double videoSaturation: (typeof wallpaper !== 'undefined' && wallpaper.configuration.VideoSaturation !== undefined) ? wallpaper.configuration.VideoSaturation : 1.0
    readonly property double videoContrast: (typeof wallpaper !== 'undefined' && wallpaper.configuration.VideoContrast !== undefined) ? wallpaper.configuration.VideoContrast : 1.0
    readonly property double videoBrightness: (typeof wallpaper !== 'undefined' && wallpaper.configuration.VideoBrightness !== undefined) ? wallpaper.configuration.VideoBrightness : 1.0
    readonly property bool pauseOnBattery: (typeof wallpaper !== 'undefined' && wallpaper.configuration.PauseOnBattery !== undefined) ? wallpaper.configuration.PauseOnBattery : false
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
        pauseOnBattery: root.pauseOnBattery
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
        
        // Ocultar al haber errores o suspensión para no consumir recursos de renderizado
        visible: !controller.hasError && !controller.isSuspended && root.videoSource !== ""
        
        // Enlazar y desenlazar de forma segura el reproductor multimedia con este visualizador
        Component.onCompleted: {
            if (controller.mediaPlayer) {
                controller.mediaPlayer.videoOutput = videoOutput.videoSink;
            }
        }

        Component.onDestruction: {
            controller.detachVideoOutput();
        }

        // Animaciones para transiciones fluidas (smooth transitions)
        opacity: visible ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
        }
    }

    // Capa ligera de post-procesado sin FBOs (evita QQuickShaderEffectSource::updatePaintNode)
    Item {
        id: colorAdjustmentLayer
        anchors.fill: parent
        visible: videoOutput.visible && (
            Math.abs(root.videoSaturation - 1.0) > 0.01 ||
            Math.abs(root.videoContrast - 1.0) > 0.01 ||
            Math.abs(root.videoBrightness - 1.0) > 0.01
        )
        opacity: videoOutput.opacity

        // Ajuste de brillo / exposición (aclarado u oscurecimiento directo)
        Rectangle {
            anchors.fill: parent
            visible: Math.abs(root.videoBrightness - 1.0) > 0.01
            color: root.videoBrightness > 1.0 ? "#ffffff" : "#000000"
            opacity: Math.min(Math.abs(root.videoBrightness - 1.0) * 0.55, 0.75)
        }

        // Ajuste de contraste mediante gradiente de luminancia de bordes y centro
        Rectangle {
            anchors.fill: parent
            visible: Math.abs(root.videoContrast - 1.0) > 0.01
            color: "transparent"
            opacity: Math.min(Math.abs(root.videoContrast - 1.0) * 0.45, 0.65)
            gradient: Gradient {
                GradientStop { position: 0.0; color: root.videoContrast > 1.0 ? "#50000000" : "#40808080" }
                GradientStop { position: 0.5; color: root.videoContrast > 1.0 ? "#18ffffff" : "#40808080" }
                GradientStop { position: 1.0; color: root.videoContrast > 1.0 ? "#65000000" : "#40808080" }
            }
        }

        // Ajuste de saturación y viveza cromática (desaturación < 1.0 y realce cálido/profundo > 1.0)
        Rectangle {
            anchors.fill: parent
            visible: Math.abs(root.videoSaturation - 1.0) > 0.01
            color: root.videoSaturation < 1.0 ? "#808080" : "transparent"
            opacity: root.videoSaturation < 1.0
                ? Math.min((1.0 - root.videoSaturation) * 0.85, 0.85)
                : Math.min((root.videoSaturation - 1.0) * 0.28, 0.35)
            gradient: root.videoSaturation > 1.0 ? vibrantGradient : null
        }

        Gradient {
            id: vibrantGradient
            GradientStop { position: 0.0; color: "#351a0a2e" }
            GradientStop { position: 0.5; color: "#15ff7b29" }
            GradientStop { position: 1.0; color: "#40091526" }
        }
    }

    // Superposición cinematográfica de viñeta simétrica en 4 lados (Cinematic 4-edge Vignette)
    Item {
        id: premiumOverlay
        anchors.fill: parent
        visible: root.showOverlay && videoOutput.visible
        opacity: videoOutput.opacity * Math.min(1.0, Math.max(0.1, root.vignetteSaturation * 1.4))

        // Viñeta vertical (superior e inferior)
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, Math.min(0.9, 0.55 * root.vignetteSaturation * 1.6)) }
                GradientStop { position: 0.25; color: Qt.rgba(0, 0, 0, Math.min(0.4, 0.12 * root.vignetteSaturation * 1.6)) }
                GradientStop { position: 0.5; color: "transparent" }
                GradientStop { position: 0.75; color: Qt.rgba(0, 0, 0, Math.min(0.45, 0.18 * root.vignetteSaturation * 1.6)) }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, Math.min(0.95, 0.75 * root.vignetteSaturation * 1.6)) }
            }
        }

        // Viñeta horizontal (izquierda y derecha)
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, Math.min(0.85, 0.45 * root.vignetteSaturation * 1.5)) }
                GradientStop { position: 0.2; color: "transparent" }
                GradientStop { position: 0.8; color: "transparent" }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, Math.min(0.85, 0.45 * root.vignetteSaturation * 1.5)) }
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
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
