import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Notifications
import "../../theme"

Rectangle {
    id: card
    // `var` accepts both live Notification objects (from DBus) and revived
    // plain JS objects loaded from disk — a typed `Notification` property
    // rejects QVariantMaps and leaves the prop null.
    required property var notification

    width: parent ? parent.width : Theme.layout.panelWidth
    height: content.implicitHeight + 24
    radius: Theme.layout.cardRadius
    color: Theme.colors.surface
    border.width: 1
    border.color: urgencyColor

    readonly property color urgencyColor: {
        if (!notification) return Theme.colors.border
        if (notification.urgency === NotificationUrgency.Critical) return Theme.colors.danger
        if (notification.urgency === NotificationUrgency.Low) return Theme.colors.textMuted
        return Theme.colors.border
    }

    Behavior on color { ColorAnimation { duration: Theme.animation } }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        hoverEnabled: true
        onEntered: card.color = Theme.colors.surfaceHover
        onExited: card.color = Theme.colors.surface
    }

    RowLayout {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
        spacing: 10

        Image {
            visible: card.notification.image !== ""
            source: card.notification.image
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignTop
            fillMode: Image.PreserveAspectCrop
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: card.notification.summary
                    color: Theme.colors.text
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.sizeNormal
                    font.weight: Theme.font.weightBold
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Text {
                    text: {
                        const t = card.notification.time
                        return t ? Qt.formatTime(t, "hh:mm") : ""
                    }
                    color: Theme.colors.textMuted
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.sizeSmall
                }
                Button {
                    id: dismissBtn
                    flat: true
                    implicitWidth: 22
                    implicitHeight: 22
                    onClicked: card.notification.dismiss()

                    contentItem: Text {
                        text: "󰅖"
                        color: dismissBtn.hovered ? Theme.colors.text : Theme.colors.textMuted
                        font.family: Theme.font.family
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: 4
                        color: dismissBtn.hovered ? Theme.colors.surfaceHover : "transparent"
                    }
                }
            }

            Text {
                visible: card.notification.body !== ""
                text: card.notification.body
                textFormat: card.notification.bodyMarkup ? Text.RichText : Text.PlainText
                color: Theme.colors.textMuted
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeSmall
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
                maximumLineCount: 3
                elide: Text.ElideRight
            }

            RowLayout {
                visible: card.notification.actions.length > 0
                spacing: 6
                Repeater {
                    model: card.notification.actions
                    delegate: Button {
                        required property var modelData
                        text: modelData.text
                        onClicked: modelData.invoke()
                    }
                }
            }
        }
    }
}
