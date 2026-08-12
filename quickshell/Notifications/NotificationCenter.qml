import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "config.js" as Config

PanelWindow {
    id: center
    visible: false   // toggle via IpcHandler in Notifications.qml, or a bar widget

    anchors { top: true; right: true }
    margins { top: Config.layout.margin; right: Config.layout.margin }
    implicitWidth: Config.layout.panelWidth
    implicitHeight: 600
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusiveZone: 0

    function toggle() { visible = !visible }
    function close() { visible = false }

    // Click-outside-to-close: grabs input focus while the panel is open;
    // any click landing outside the listed windows fires `cleared`. Hard
    // couples this to Hyprland — if you ever go compositor-agnostic, swap
    // this for a full-screen transparent input-catcher window instead.
    HyprlandFocusGrab {
        id: focusGrab
        windows: [center]
        active: center.visible
        onCleared: center.close()
    }

    Rectangle {
        anchors.fill: parent
        radius: Config.layout.cardRadius
        color: Config.colors.background
        border.width: 1
        border.color: Config.colors.border

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Notifications"
                    color: Config.colors.text
                    font.family: Config.font.family
                    font.pixelSize: Config.font.sizeLarge
                    font.weight: Config.font.weightBold
                    Layout.fillWidth: true
                }
                Button {
                    text: "Clear All"
                    flat: true
                    visible: NotificationDaemon.history.length > 0
                    onClicked: NotificationDaemon.clearAll()
                }
            }

            MediaControls { Layout.fillWidth: true }

            VolumeSlider { Layout.fillWidth: true }
            BrightnessSlider { Layout.fillWidth: true }

            Rectangle { Layout.fillWidth: true; height: 1; color: Config.colors.border }

            Text {
                visible: NotificationDaemon.history.length === 0
                text: "No notifications"
                color: Config.colors.textMuted
                font.family: Config.font.family
                font.pixelSize: Config.font.sizeSmall
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 24
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: Config.layout.cardSpacing
                model: NotificationDaemon.history
                delegate: NotificationCard {
                    required property var modelData
                    width: ListView.view.width
                    notification: modelData
                }
            }
        }
    }
}
