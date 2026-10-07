import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "config.js" as Config

PanelWindow {
    id: popup
    visible: false   // toggle via IpcHandler in shell.qml

    anchors { top: true; right: true }
    margins { top: Config.layout.margin; right: Config.layout.wifiRightMargin }
    implicitWidth: Config.layout.panelWidth
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
        radius: Config.layout.cardRadius
        color: Config.colors.background
        border.width: 1
        border.color: Config.colors.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "WiFi"
                    color: Config.colors.text
                    font.family: Config.font.family
                    font.pixelSize: Config.font.sizeLarge
                    font.weight: Config.font.weightBold
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
                color: Config.colors.danger
                font.family: Config.font.family
                font.pixelSize: Config.font.sizeSmall
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Text {
                visible: WifiManager.available && WifiManager.lastError !== ""
                text: WifiManager.lastError
                color: Config.colors.danger
                font.family: Config.font.family
                font.pixelSize: Config.font.sizeSmall
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Text {
                visible: WifiManager.available && !WifiManager.enabled
                text: "WiFi is off"
                color: Config.colors.textMuted
                font.family: Config.font.family
                font.pixelSize: Config.font.sizeSmall
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 24
            }

            Text {
                visible: WifiManager.enabled && WifiManager.networks.length === 0
                text: WifiManager.scanning ? "Scanning..." : "No networks found"
                color: Config.colors.textMuted
                font.family: Config.font.family
                font.pixelSize: Config.font.sizeSmall
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 24
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: WifiManager.enabled
                clip: true
                spacing: Config.layout.rowSpacing
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
