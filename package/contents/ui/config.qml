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
            "showOverlay": "Superposición Premium:",
            "overlayDesc": "Agrega un degradado y viñeta sutiles al fondo para mejorar el contraste.",
            "fileDialogTitle": "Selecciona un archivo de video",
            "folderDialogTitle": "Selecciona una carpeta de videos",
            "playlistDialogTitle": "Selecciona múltiples archivos de video"
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
            "showOverlay": "Premium Overlay:",
            "overlayDesc": "Adds a subtle gradient and vignette to the background to improve contrast.",
            "fileDialogTitle": "Select a video file",
            "folderDialogTitle": "Select a video folder",
            "playlistDialogTitle": "Select multiple video files"
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
    property alias cfg_SourceType: sourceTypeCombo.currentIndex
    property alias cfg_Mute: muteSwitch.checked
    property alias cfg_LoopMode: loopModeCombo.currentIndex
    property alias cfg_PlaylistOrder: playlistOrderCombo.currentIndex

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
}
