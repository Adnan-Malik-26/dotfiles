import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "config.js" as Config

PanelWindow {
    id: osd
    visible: false

    anchors { bottom: true }
    margins { bottom: 80 }
    implicitWidth: Config.layout.osdWidth
    implicitHeight: Config.layout.osdHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusiveZone: 0

    property string mode: "volume"   // "volume" | "brightness" | "capslock"
    property real level: 0            // 0..1, meaning depends on mode

    readonly property string iconGlyph: {
        if (mode === "volume") return level < 0 ? "󰝟" : "󰕾"
        if (mode === "brightness") return "󰃠"
        return "󰌌"   // capslock → keyboard icon
    }

    function show(newMode, newLevel) {
        mode = newMode
        level = newLevel
        visible = true
        hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: Config.timeout.osd
        onTriggered: osd.visible = false
    }

    // React to state changes anywhere in the app — hotkeys, sliders, or
    // external tools (pactl, brightnessctl run from a terminal) all surface
    // here identically, since everything reads from the same singletons.
    Connections {
        target: Audio
        function onVolumeChanged() { osd.show("volume", Audio.muted ? -1 : Audio.volume) }
        function onMutedChanged() { osd.show("volume", Audio.muted ? -1 : Audio.volume) }
    }

    Connections {
        target: Brightness
        function onValueChanged() { osd.show("brightness", Brightness.value) }
    }

    Connections {
        target: CapsLock
        function onActiveChanged() { osd.show("capslock", CapsLock.active ? 1 : 0) }
    }

    Rectangle {
        anchors.fill: parent
        radius: Config.layout.cardRadius
        color: Config.colors.background
        border.width: 1
        border.color: Config.colors.border

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Text {
                text: osd.iconGlyph
                color: Config.colors.text
                font.family: Config.font.family
                font.pixelSize: 20
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                visible: osd.mode !== "capslock"
                Layout.fillWidth: true
                Layout.preferredHeight: 6
                radius: 3
                color: Config.colors.sliderTrack

                Rectangle {
                    width: parent.width * Math.max(0, osd.level)
                    height: parent.height
                    radius: 3
                    color: Config.colors.sliderFill
                }
            }

            Text {
                visible: osd.mode === "capslock"
                text: osd.level > 0 ? "Caps Lock ON" : "Caps Lock OFF"
                color: Config.colors.text
                font.family: Config.font.family
                font.pixelSize: Config.font.sizeSmall
                Layout.fillWidth: true
            }
        }
    }
}
