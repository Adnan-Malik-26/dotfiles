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
    visible: Panels.current === "bluetooth"

    anchors { top: true; right: true }
    margins { top: Theme.layout.margin; right: Theme.layout.margin }
    implicitWidth: Theme.layout.panelWidthCompact
    implicitHeight: 420
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusiveZone: 0

    function toggle() { Panels.toggle("bluetooth") }
    function close() { Panels.close("bluetooth") }
    onVisibleChanged: {
        if (visible) BluetoothManager.startDiscovery()
        else BluetoothManager.stopDiscovery()
    }

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
                    text: "Bluetooth"
                    color: Theme.colors.text
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.sizeLarge
                    font.weight: Theme.font.weightBold
                    Layout.fillWidth: true
                }
                Button {
                    flat: true
                    implicitWidth: 30
                    text: BluetoothManager.discovering ? "󰑐" : "󰑓"
                    enabled: BluetoothManager.enabled
                    onClicked: BluetoothManager.discovering ? BluetoothManager.stopDiscovery() : BluetoothManager.startDiscovery()
                }
                Switch {
                    checked: BluetoothManager.enabled
                    onToggled: BluetoothManager.toggleAdapter()
                }
            }

            Text {
                visible: !BluetoothManager.available
                text: "No Bluetooth adapter found — is bluez running?"
                color: Theme.colors.danger
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeSmall
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Text {
                visible: BluetoothManager.available && !BluetoothManager.enabled
                text: "Bluetooth is off"
                color: Theme.colors.textMuted
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeSmall
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 24
            }

            Text {
                visible: BluetoothManager.enabled && BluetoothManager.devices.count === 0
                text: BluetoothManager.discovering ? "Scanning..." : "No devices found"
                color: Theme.colors.textMuted
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeSmall
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 24
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: BluetoothManager.enabled
                clip: true
                spacing: Theme.layout.rowSpacing
                model: BluetoothManager.devices
                delegate: DeviceItem {
                    required property var modelData
                    width: ListView.view.width
                    device: modelData
                }
            }
        }
    }
}
