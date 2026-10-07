import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Bluetooth
import "config.js" as Config

Rectangle {
    id: item
    required property BluetoothDevice device

    width: parent ? parent.width : Config.layout.panelWidth
    height: content.implicitHeight + 20
    radius: Config.layout.rowRadius
    color: Config.colors.surface
    border.width: 1
    border.color: device && device.connected ? Config.colors.accent : Config.colors.border

    Behavior on color { ColorAnimation { duration: Config.timeout.animation } }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        onEntered: if (item.device && !item.device.connected) item.color = Config.colors.surfaceHover
        onExited: if (item.device && !item.device.connected) item.color = Config.colors.surface
    }

    RowLayout {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
        spacing: 10

        Text {
            text: item.device && item.device.paired ? "󰂱" : "󰂯"
            color: item.device && item.device.connected ? Config.colors.accent : Config.colors.text
            font.family: Config.font.family
            font.pixelSize: Config.font.sizeNormal + 4
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text {
                text: item.device ? (item.device.name !== "" ? item.device.name : item.device.address) : ""
                color: Config.colors.text
                font.family: Config.font.family
                font.pixelSize: Config.font.sizeNormal
                font.weight: item.device && item.device.connected ? Config.font.weightBold : Font.Normal
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text: {
                    if (!item.device) return ""
                    if (item.device.pairing) return "Pairing..."
                    if (item.device.connected) return item.device.batteryAvailable
                        ? "Connected · " + Math.round(item.device.battery * 100) + "%"
                        : "Connected"
                    return item.device.paired ? "Paired" : "Available"
                }
                color: item.device && item.device.connected ? Config.colors.success : Config.colors.textMuted
                font.family: Config.font.family
                font.pixelSize: Config.font.sizeSmall
            }
        }

        Button {
            text: item.device && item.device.connected ? "Disconnect" : (item.device && item.device.paired ? "Connect" : "Pair")
            enabled: item.device && !item.device.pairing
            flat: true
            onClicked: {
                if (item.device.connected) {
                    BluetoothManager.disconnectDevice(item.device)
                } else if (item.device.paired) {
                    BluetoothManager.connectDevice(item.device)
                } else {
                    BluetoothManager.pairDevice(item.device)
                }
            }
        }

        Button {
            visible: item.device && (item.device.paired || item.device.bonded)
            flat: true
            implicitWidth: 26
            text: "󰆴"
            onClicked: BluetoothManager.forgetDevice(item.device)
        }
    }
}
