import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami

Kirigami.FormLayout {
    id: root
    twinFormLayouts: parentLayout
    property alias formLayout: root

    // Configuración y detección de idioma (locale)
    readonly property bool isSpanish: Qt.locale().name.indexOf("es") === 0
    readonly property var texts: {
        "es": {
            "title": "Configuración de Raven Wallpaper Engine",
            "sourceType": "Origen de los vídeos:",
            "singleFile": "Archivo Único",
            "directory": "Carpeta (Directorio)",
            "multipleFiles": "Varios Archivos (Playlist)",
            "videoSource": "Ruta / Origen:",
            "selectVideo": "Seleccionar Vídeo...",
            "selectFolder": "Seleccionar Carpeta...",
            "selectVideos": "Seleccionar Vídeos...",
            "fallbackColor": "Color de Fondo (Fallback):",
            "mute": "Silenciar Audio:",
            "volume": "Volumen de Audio:",
            "muted": "Silenciado",
            "loopMode": "Modo de Bucle:",
            "loopSingle": "Bucle al Vídeo Actual",
            "playOnce": "Reproducir Lista una Vez",
            "loopList": "Bucle a toda la Lista",
            "playlistOrder": "Orden de Lista:",
            "sequential": "Secuencial",
            "random": "Aleatorio (Shuffle)",
            "playbackRate": "Velocidad:",
            "fillMode": "Modo de Ajuste:",
            "stretch": "Estirar",
            "aspectFit": "Ajustar con Aspecto",
            "aspectCrop": "Recortar con Aspecto",
            "showOverlay": "Viñeteado y Superposición:",
            "overlayDesc": "Agrega un degradado y viñeta sutiles al fondo para mejorar el contraste.",
            "vignetteSaturation": "Saturación del Viñeteado:",
            "imageQualityHeader": "Calidad de Imagen y Reproducción",
            "videoSaturation": "Saturación de Color:",
            "videoContrast": "Contraste de Video:",
            "videoBrightness": "Brillo / Exposición:",
            "resetBtn": "Restablecer",
            "powerHeader": "Rendimiento y Ahorro de Energía",
            "pauseOnBattery": "Pausar en Batería / Ahorro:",
            "pauseOnBatteryDesc": "Suspende automáticamente la decodificación de video cuando la laptop se desconecta de la corriente o entra en perfil de ahorro de energía.",
            "fileDialogTitle": "Selecciona un archivo de video",
            "folderDialogTitle": "Selecciona una carpeta de videos",
            "playlistDialogTitle": "Selecciona múltiples archivos de video",
            "showFrame": "Marco Redondeado:",
            "frameDesc": "Agrega un borde decorativo redondeado sobre el escritorio.",
            "frameThickness": "Grosor del marco:",
            "frameRadius": "Curvatura (Radio):",
            "frameColor": "Color del marco:"
        },
        "en": {
            "title": "Raven Wallpaper Engine Settings",
            "sourceType": "Video Source Type:",
            "singleFile": "Single File",
            "directory": "Folder (Directory)",
            "multipleFiles": "Multiple Files (Playlist)",
            "videoSource": "Path / Source:",
            "selectVideo": "Select Video...",
            "selectFolder": "Select Folder...",
            "selectVideos": "Select Videos...",
            "fallbackColor": "Fallback Color:",
            "mute": "Mute Audio:",
            "volume": "Audio Volume:",
            "muted": "Muted",
            "loopMode": "Loop Mode:",
            "loopSingle": "Loop Current Video",
            "playOnce": "Play List Once",
            "loopList": "Loop Full List",
            "playlistOrder": "Playlist Order:",
            "sequential": "Sequential",
            "random": "Random (Shuffle)",
            "playbackRate": "Speed Rate:",
            "fillMode": "Scaling Mode:",
            "stretch": "Stretch",
            "aspectFit": "Preserve Aspect Fit",
            "aspectCrop": "Preserve Aspect Crop",
            "showOverlay": "Vignette & Overlay:",
            "overlayDesc": "Adds a subtle gradient and vignette to the background to improve contrast.",
            "vignetteSaturation": "Vignette Saturation:",
            "imageQualityHeader": "Image & Playback Quality",
            "videoSaturation": "Color Saturation:",
            "videoContrast": "Video Contrast:",
            "videoBrightness": "Brightness / Exposure:",
            "resetBtn": "Reset",
            "powerHeader": "Performance & Power Saving",
            "pauseOnBattery": "Pause on Battery / Power Saver:",
            "pauseOnBatteryDesc": "Automatically suspends video decoding when running on battery power or when Power Saver profile is active.",
            "fileDialogTitle": "Select a video file",
            "folderDialogTitle": "Select a video folder",
            "playlistDialogTitle": "Select multiple video files",
            "showFrame": "Rounded Frame:",
            "frameDesc": "Adds a decorative rounded border over the desktop.",
            "frameThickness": "Frame Thickness:",
            "frameRadius": "Corner Radius:",
            "frameColor": "Frame Color:"
        }
    }
    readonly property var t: isSpanish ? texts["es"] : texts["en"]

    // Propiedades vinculadas a la configuración (KConfigXT)
    property alias cfg_VideoSource: videoSourceInput.text
    property alias cfg_FallbackColor: fallbackColorInput.text
    property alias cfg_Volume: volumeSlider.value
    property alias cfg_PlaybackRate: speedSlider.value
    property alias cfg_FillMode: fillModeCombo.currentIndex
    property alias cfg_ShowOverlay: overlaySwitch.checked
    property alias cfg_VignetteSaturation: vignetteSatSlider.value
    property alias cfg_VideoSaturation: videoSatSlider.value
    property alias cfg_VideoContrast: videoContrastSlider.value
    property alias cfg_VideoBrightness: videoBrightnessSlider.value
    property alias cfg_PauseOnBattery: pauseOnBatterySwitch.checked
    property alias cfg_SourceType: sourceTypeCombo.currentIndex
    property alias cfg_Mute: muteSwitch.checked
    property alias cfg_LoopMode: loopModeCombo.currentIndex
    property alias cfg_PlaylistOrder: playlistOrderCombo.currentIndex
    property alias cfg_ShowFrame: frameSwitch.checked
    property alias cfg_FrameThickness: frameThicknessSlider.value
    property alias cfg_FrameRadius: frameRadiusSlider.value
    property alias cfg_FrameColor: frameColorInput.text

    // Cuadros de diálogo (dialogs)
    FileDialog {
        id: fileDialogSingle
        title: root.t.fileDialogTitle
        nameFilters: ["Video files (*.mp4 *.mkv *.avi *.mov *.webm *.ogv)", "All files (*)"]
        onAccepted: {
            videoSourceInput.text = fileDialogSingle.selectedFile.toString()
        }
    }

    FolderDialog {
        id: folderDialog
        title: root.t.folderDialogTitle
        onAccepted: {
            videoSourceInput.text = folderDialog.selectedFolder.toString()
        }
    }

    FileDialog {
        id: fileDialogPlaylist
        title: root.t.playlistDialogTitle
        fileMode: FileDialog.OpenFiles
        nameFilters: ["Video files (*.mp4 *.mkv *.avi *.mov *.webm *.ogv)", "All files (*)"]
        onAccepted: {
            var files = fileDialogPlaylist.selectedFiles
            var paths = []
            for (var i = 0; i < files.length; ++i) {
                paths.push(files[i].toString())
            }
            videoSourceInput.text = paths.join(";")
        }
    }

    // Título de sección (heading)
    Kirigami.Heading {
        Layout.fillWidth: true
        text: root.t.title
        level: 2
        horizontalAlignment: Text.AlignHCenter
        bottomPadding: Kirigami.Units.largeSpacing
    }

    // Selector de origen (source type)
    ComboBox {
        id: sourceTypeCombo
        Kirigami.FormData.label: root.t.sourceType
        Layout.fillWidth: true
        model: [root.t.singleFile, root.t.directory, root.t.multipleFiles]
    }

    // Campo de texto y botón de selección (file picker)
    RowLayout {
        Kirigami.FormData.label: root.t.videoSource
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        TextField {
            id: videoSourceInput
            Layout.fillWidth: true
            placeholderText: {
                if (sourceTypeCombo.currentIndex === 0) return "file:///path/to/video.mp4"
                if (sourceTypeCombo.currentIndex === 1) return "file:///path/to/video_directory"
                return "file:///vid1.mp4;file:///vid2.mp4"
            }
        }

        Button {
            icon.name: {
                if (sourceTypeCombo.currentIndex === 1) return "folder-open"
                return "document-open"
            }
            text: {
                if (sourceTypeCombo.currentIndex === 0) return root.t.selectVideo
                if (sourceTypeCombo.currentIndex === 1) return root.t.selectFolder
                return root.t.selectVideos
            }
            onClicked: {
                if (sourceTypeCombo.currentIndex === 0) {
                    fileDialogSingle.open()
                } else if (sourceTypeCombo.currentIndex === 1) {
                    folderDialog.open()
                } else {
                    fileDialogPlaylist.open()
                }
            }
        }
    }

    // Selección de modo de bucle (loop mode)
    ComboBox {
        id: loopModeCombo
        Kirigami.FormData.label: root.t.loopMode
        Layout.fillWidth: true
        model: [root.t.loopSingle, root.t.playOnce, root.t.loopList]
    }

    // Selección del orden de reproducción (playlist order)
    ComboBox {
        id: playlistOrderCombo
        Kirigami.FormData.label: root.t.playlistOrder
        Layout.fillWidth: true
        visible: sourceTypeCombo.currentIndex !== 0
        model: [root.t.sequential, root.t.random]
    }

    // Color de fondo alternativo (fallback color)
    RowLayout {
        Kirigami.FormData.label: root.t.fallbackColor
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        TextField {
            id: fallbackColorInput
            Layout.fillWidth: true
            placeholderText: "#121214"
        }

        Rectangle {
            width: Kirigami.Units.gridUnit
            height: Kirigami.Units.gridUnit
            color: {
                try {
                    return fallbackColorInput.text !== "" ? fallbackColorInput.text : "#121214"
                } catch(e) {
                    return "#121214"
                }
            }
            border.color: Kirigami.Theme.textColor
            border.width: 1
            radius: 3
        }
    }

    // Silenciador de audio (mute)
    Switch {
        id: muteSwitch
        Kirigami.FormData.label: root.t.mute
    }

    // Nivel de volumen de audio (volume)
    RowLayout {
        Kirigami.FormData.label: root.t.volume
        Layout.fillWidth: true
        enabled: !muteSwitch.checked

        Slider {
            id: volumeSlider
            Layout.fillWidth: true
            from: 0.0
            to: 1.0
            stepSize: 0.05
        }

        Label {
            text: muteSwitch.checked ? root.t.muted : Math.round(volumeSlider.value * 100) + "%"
            width: Kirigami.Units.gridUnit * 3
            horizontalAlignment: Text.AlignRight
            color: muteSwitch.checked ? Kirigami.Theme.disabledTextColor : Kirigami.Theme.textColor
        }
    }

    // Velocidad de reproducción de video (playback rate)
    RowLayout {
        Kirigami.FormData.label: root.t.playbackRate
        Layout.fillWidth: true

        Slider {
            id: speedSlider
            Layout.fillWidth: true
            from: 0.5
            to: 2.0
            stepSize: 0.1
        }

        Label {
            text: speedSlider.value.toFixed(1) + "x"
            width: Kirigami.Units.gridUnit * 3
            horizontalAlignment: Text.AlignRight
        }

        ToolButton {
            icon.name: "edit-undo"
            ToolTip.visible: hovered
            ToolTip.text: root.t.resetBtn
            enabled: Math.abs(speedSlider.value - 1.0) > 0.01
            onClicked: speedSlider.value = 1.0
        }
    }

    // Pausar automáticamente al usar batería o modo ahorro de energía
    ColumnLayout {
        Kirigami.FormData.label: root.t.pauseOnBattery
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        Switch {
            id: pauseOnBatterySwitch
        }

        Label {
            text: root.t.pauseOnBatteryDesc
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }

    // Modo de ajuste visual (fill mode)
    ComboBox {
        id: fillModeCombo
        Kirigami.FormData.label: root.t.fillMode
        Layout.fillWidth: true
        model: [root.t.stretch, root.t.aspectFit, root.t.aspectCrop]
    }

    // Habilitar superposición de interfaz (premium overlay)
    ColumnLayout {
        Kirigami.FormData.label: root.t.showOverlay
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        Switch {
            id: overlaySwitch
        }

        Label {
            text: root.t.overlayDesc
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }

    // Grado de saturación / intensidad del viñeteado
    RowLayout {
        Kirigami.FormData.label: root.t.vignetteSaturation
        Layout.fillWidth: true
        visible: overlaySwitch.checked

        Slider {
            id: vignetteSatSlider
            Layout.fillWidth: true
            from: 0.0
            to: 1.0
            stepSize: 0.05
        }

        Label {
            text: Math.round(vignetteSatSlider.value * 100) + "%"
            width: Kirigami.Units.gridUnit * 3
            horizontalAlignment: Text.AlignRight
        }
    }

    Kirigami.Separator { Layout.fillWidth: true }

    // Sección de Calidad de Imagen y Reproducción
    Kirigami.Heading {
        Layout.fillWidth: true
        text: root.t.imageQualityHeader
        level: 3
        topPadding: Kirigami.Units.mediumSpacing
        bottomPadding: Kirigami.Units.smallSpacing
    }

    // Saturación de color del vídeo
    RowLayout {
        Kirigami.FormData.label: root.t.videoSaturation
        Layout.fillWidth: true

        Slider {
            id: videoSatSlider
            Layout.fillWidth: true
            from: 0.0
            to: 2.0
            stepSize: 0.05
        }

        Label {
            text: Math.round(videoSatSlider.value * 100) + "%"
            width: Kirigami.Units.gridUnit * 3
            horizontalAlignment: Text.AlignRight
        }

        ToolButton {
            icon.name: "edit-undo"
            ToolTip.visible: hovered
            ToolTip.text: root.t.resetBtn
            enabled: Math.abs(videoSatSlider.value - 1.0) > 0.01
            onClicked: videoSatSlider.value = 1.0
        }
    }

    // Contraste del vídeo
    RowLayout {
        Kirigami.FormData.label: root.t.videoContrast
        Layout.fillWidth: true

        Slider {
            id: videoContrastSlider
            Layout.fillWidth: true
            from: 0.0
            to: 2.0
            stepSize: 0.05
        }

        Label {
            text: Math.round(videoContrastSlider.value * 100) + "%"
            width: Kirigami.Units.gridUnit * 3
            horizontalAlignment: Text.AlignRight
        }

        ToolButton {
            icon.name: "edit-undo"
            ToolTip.visible: hovered
            ToolTip.text: root.t.resetBtn
            enabled: Math.abs(videoContrastSlider.value - 1.0) > 0.01
            onClicked: videoContrastSlider.value = 1.0
        }
    }

    // Brillo / Exposición del vídeo
    RowLayout {
        Kirigami.FormData.label: root.t.videoBrightness
        Layout.fillWidth: true

        Slider {
            id: videoBrightnessSlider
            Layout.fillWidth: true
            from: 0.2
            to: 1.8
            stepSize: 0.05
        }

        Label {
            text: Math.round(videoBrightnessSlider.value * 100) + "%"
            width: Kirigami.Units.gridUnit * 3
            horizontalAlignment: Text.AlignRight
        }

        ToolButton {
            icon.name: "edit-undo"
            ToolTip.visible: hovered
            ToolTip.text: root.t.resetBtn
            enabled: Math.abs(videoBrightnessSlider.value - 1.0) > 0.01
            onClicked: videoBrightnessSlider.value = 1.0
        }
    }

    Kirigami.Separator { Layout.fillWidth: true }

    // Habilitar marco decorativo (Rounded Frame)
    ColumnLayout {
        Kirigami.FormData.label: root.t.showFrame
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        Switch {
            id: frameSwitch
        }

        Label {
            text: root.t.frameDesc
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            color: Kirigami.Theme.disabledTextColor
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }

    // Grosor del marco
    RowLayout {
        Kirigami.FormData.label: root.t.frameThickness
        Layout.fillWidth: true
        visible: frameSwitch.checked

        Slider {
            id: frameThicknessSlider
            Layout.fillWidth: true
            from: 1
            to: 50
            stepSize: 1
        }

        Label {
            text: frameThicknessSlider.value + " px"
            width: Kirigami.Units.gridUnit * 3
            horizontalAlignment: Text.AlignRight
        }
    }

    // Radio de las esquinas (Corner Radius)
    RowLayout {
        Kirigami.FormData.label: root.t.frameRadius
        Layout.fillWidth: true
        visible: frameSwitch.checked

        Slider {
            id: frameRadiusSlider
            Layout.fillWidth: true
            from: 0
            to: 100
            stepSize: 1
        }

        Label {
            text: frameRadiusSlider.value + " px"
            width: Kirigami.Units.gridUnit * 3
            horizontalAlignment: Text.AlignRight
        }
    }

    // Color del marco (Soporta transparencia Hex ARGB/RGBA)
    RowLayout {
        Kirigami.FormData.label: root.t.frameColor
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing
        visible: frameSwitch.checked

        Button {
            id: colorButton
            Layout.fillWidth: true
            
            contentItem: RowLayout {
                spacing: Kirigami.Units.smallSpacing
                
                Rectangle {
                    width: Kirigami.Units.gridUnit
                    height: Kirigami.Units.gridUnit
                    color: {
                        try {
                            return frameColorInput.text !== "" ? frameColorInput.text : "#80ffffff"
                        } catch(e) {
                            return "#80ffffff"
                        }
                    }
                    border.color: Kirigami.Theme.textColor
                    border.width: 1
                    radius: 3
                }
                
                Label {
                    text: frameColorInput.text !== "" ? frameColorInput.text : "#80ffffff"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            
            onClicked: frameColorDialog.open()
        }

        TextField {
            id: frameColorInput
            visible: false
            text: "#80ffffff"
        }
        
        ColorDialog {
            id: frameColorDialog
            title: root.t.frameColor
            selectedColor: frameColorInput.text !== "" ? frameColorInput.text : "#80ffffff"
            options: ColorDialog.ShowAlphaChannel
            onAccepted: {
                frameColorInput.text = frameColorDialog.selectedColor.toString()
            }
        }
    }
}
