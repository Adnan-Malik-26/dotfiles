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
    margins { top: Config.layout.margin; right: Config.layout.bluetoothRightMargin }
    implicitWidth: Config.layout.panelWidth
    implicitHeight: 420
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    exclusiveZone: 0

    function toggle() {
        visible = !visible
        if (visible) BluetoothManager.startDiscovery()
        else BluetoothManager.stopDiscovery()
    }
    function close() {
        visible = false
        BluetoothManager.stopDiscovery()
    }

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
                    text: "Bluetooth"
                    color: Config.colors.text
                    font.family: Config.font.family
                    font.pixelSize: Config.font.sizeLarge
                    font.weight: Config.font.weightBold
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
                color: Config.colors.danger
                font.family: Config.font.family
                font.pixelSize: Config.font.sizeSmall
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            Text {
                visible: BluetoothManager.available && !BluetoothManager.enabled
                text: "Bluetooth is off"
                color: Config.colors.textMuted
                font.family: Config.font.family
                font.pixelSize: Config.font.sizeSmall
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 24
            }

            Text {
                visible: BluetoothManager.enabled && BluetoothManager.devices.count === 0
                text: BluetoothManager.discovering ? "Scanning..." : "No devices found"
                color: Config.colors.textMuted
                font.family: Config.font.family
                font.pixelSize: Config.font.sizeSmall
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 24
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: BluetoothManager.enabled
                clip: true
                spacing: Config.layout.rowSpacing
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
