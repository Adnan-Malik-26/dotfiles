import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../theme"
import "../../services"

PanelWindow {
    id: popup
    visible: false   // toggle via IpcHandler in shell.qml

    anchors { top: true; right: true }
    margins { top: Theme.layout.margin; right: Theme.layout.margin }
    implicitWidth: Theme.layout.panelWidthCompact
    implicitHeight: 420
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusiveZone: 0

    function toggle() {
        visible = !visible
        if (visible) WifiManager.refreshNetworks()
    }
    function close() { visible = false }

    // Same trade-off as NotificationCenter: hard-couples click-outside-to-
    // close to Hyprland. Swap for a fullscreen transparent catcher window
    // if you need compositor portability.
    HyprlandFocusGrab {
        windows: [popup]
        active: popup.visible
        onCleared: popup.close()
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.layout.cardRadius
        color: Theme.colors.background
        border.width: 1
        border.color: Theme.colors.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "WiFi"
                    color: Theme.colors.text
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.sizeLarge
                    font.weight: Theme.font.weightBold
                    Layout.fillWidth: true
                }
                Button {
                    flat: true
                    implicitWidth: 30
                    text: WifiManager.scanning ? "󰑐" : "󰑓"
                    enabled: WifiManager.enabled && !WifiManager.scanning
                    onClicked: WifiManager.rescan()
                }
                Switch {
                    checked: WifiManager.enabled
                    onToggled: WifiManager.toggleRadio()
                }
            }

            Text {
                visible: !WifiManager.available
                text: "nmcli not found — install NetworkManager"
                color: Theme.colors.danger
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeSmall
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Text {
                visible: WifiManager.available && WifiManager.lastError !== ""
                text: WifiManager.lastError
                color: Theme.colors.danger
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeSmall
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Text {
                visible: WifiManager.available && !WifiManager.enabled
                text: "WiFi is off"
                color: Theme.colors.textMuted
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeSmall
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 24
            }

            Text {
                visible: WifiManager.enabled && WifiManager.networks.length === 0
                text: WifiManager.scanning ? "Scanning..." : "No networks found"
                color: Theme.colors.textMuted
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeSmall
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 24
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: WifiManager.enabled
                clip: true
                spacing: Theme.layout.rowSpacing
                model: WifiManager.networks
                delegate: NetworkItem {
                    required property var modelData
                    width: ListView.view.width
                    network: modelData
                }
            }
        }
    }
}
