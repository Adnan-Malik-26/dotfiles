import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../../services"

Item {
    id: root
    property bool active: false

    visible: opacity > 0
    opacity: active ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: Theme.animation } }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        Text {
            text: Pomodoro.todaySummary
            color: Theme.colors.textMuted
            font.pixelSize: Theme.font.sizeSmall + 1
            font.family: Theme.font.family
        }

        ListView {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 6
            model: Pomodoro.sessions.slice().reverse()

            Text {
                anchors.centerIn: parent
                visible: Pomodoro.sessions.length === 0
                text: "no sessions yet"
                color: Theme.colors.sliderTrack
                font.pixelSize: Theme.font.sizeSmall + 1
                font.family: Theme.font.family
            }

            delegate: Rectangle {
                required property var modelData
                width: list.width
                height: 44
                radius: Theme.layout.rowRadius
                color: Theme.colors.surface
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10
                    Text {
                        Layout.fillWidth: true
                        text: modelData.tag
                        elide: Text.ElideRight
                        color: Theme.colors.text
                        font.pixelSize: Theme.font.sizeNormal
                        font.family: Theme.font.family
                    }
                    Text {
                        text: modelData.minutes + "m"
                        color: Theme.colors.textMuted
                        font.pixelSize: Theme.font.sizeSmall + 1
                        font.family: Theme.font.family
                    }
                    Text {
                        text: Qt.formatDateTime(new Date(modelData.startedAt), "dd MMM HH:mm")
                        color: Theme.colors.textMuted
                        font.pixelSize: Theme.font.sizeSmall
                        font.family: Theme.font.family
                    }
                }
            }
        }
    }
}
