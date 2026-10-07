import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"
import "../../services"

Rectangle {
    id: item
    required property var network   // {ssid, signal, secured, active, saved}

    property bool expanded: false
    property string passwordDraft: ""

    readonly property bool isConnecting: WifiManager.connectingSsid === network.ssid

    width: parent ? parent.width : Theme.layout.panelWidthCompact
    height: content.implicitHeight + 20
    radius: Theme.layout.rowRadius
    color: Theme.colors.surface
    border.width: 1
    border.color: network.active ? Theme.colors.accent : Theme.colors.border
    clip: true

    Behavior on height { NumberAnimation { duration: Theme.animation } }
    Behavior on color { ColorAnimation { duration: Theme.animation } }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        onEntered: if (!item.network.active) item.color = Theme.colors.surfaceHover
        onExited: if (!item.network.active) item.color = Theme.colors.surface
    }

    ColumnLayout {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10 }
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: {
                    const s = item.network.signal
                    if (s >= 75) return "󰤨"
                    if (s >= 50) return "󰤥"
                    if (s >= 25) return "󰤢"
                    return "󰤟"
                }
                color: item.network.active ? Theme.colors.accent : Theme.colors.text
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeNormal + 4
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: item.network.ssid
                    color: Theme.colors.text
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.sizeNormal
                    font.weight: item.network.active ? Theme.font.weightBold : Font.Normal
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: item.isConnecting ? "Connecting..." : (item.network.active ? "Connected" : (item.network.secured ? "Secured" : "Open"))
                    color: item.network.active ? Theme.colors.success : Theme.colors.textMuted
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.sizeSmall
                }
            }

            Text {
                visible: item.network.secured
                text: "󰌾"
                color: Theme.colors.textMuted
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeNormal
            }

            Button {
                text: item.network.active ? "Disconnect" : (item.isConnecting ? "..." : "Connect")
                enabled: !item.isConnecting
                flat: true
                onClicked: {
                    if (item.network.active) {
                        WifiManager.disconnectNetwork(item.network.ssid)
                    } else if (item.network.secured && !item.network.saved) {
                        item.expanded = !item.expanded
                    } else {
                        WifiManager.connectToNetwork(item.network.ssid, "")
                    }
                }
            }

            Button {
                visible: item.network.saved && !item.network.active
                flat: true
                implicitWidth: 26
                text: "󰆴"
                onClicked: WifiManager.forgetNetwork(item.network.ssid)
            }
        }

        // Inline password entry for secured, not-yet-saved networks —
        // avoids a second popup window just to type one string.
        RowLayout {
            visible: item.expanded
            Layout.fillWidth: true
            spacing: 6

            TextField {
                Layout.fillWidth: true
                placeholderText: "Password"
                echoMode: TextInput.Password
                text: item.passwordDraft
                onTextChanged: item.passwordDraft = text
                onAccepted: {
                    WifiManager.connectToNetwork(item.network.ssid, item.passwordDraft)
                    item.expanded = false
                }
            }
            Button {
                text: "Join"
                onClicked: {
                    WifiManager.connectToNetwork(item.network.ssid, item.passwordDraft)
                    item.expanded = false
                }
            }
        }
    }
}
