import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../theme"
import "../../services"

PanelWindow {
    id: center
    visible: Panels.current === "notifications"   // opened via Panels (IPC in Notifications.qml)

    anchors { top: true; right: true }
    margins { top: Theme.layout.margin; right: Theme.layout.margin }
    implicitWidth: Theme.layout.panelWidth
    implicitHeight: 600
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusiveZone: 0

    function toggle() { Panels.toggle("notifications") }
    function close() { Panels.close("notifications") }

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
        radius: Theme.layout.cardRadius
        color: Theme.colors.background
        border.width: 1
        border.color: Theme.colors.border

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Notifications"
                    color: Theme.colors.text
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.sizeLarge
                    font.weight: Theme.font.weightBold
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

            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.colors.border }

            Text {
                visible: NotificationDaemon.history.length === 0
                text: "No notifications"
                color: Theme.colors.textMuted
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeSmall
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 24
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: Theme.layout.cardSpacing
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
