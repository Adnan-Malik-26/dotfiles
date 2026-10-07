import QtQuick
import "../theme"

// Pill button / toggle used by the pomodoro and menu modules.
Rectangle {
    id: chip
    property string label
    property bool active: false
    property int padding: 24
    signal clicked()

    implicitWidth: txt.implicitWidth + padding
    implicitHeight: 30
    radius: height / 2
    color: active ? Theme.colors.text : (ma.containsMouse ? Theme.colors.surfaceHover : "transparent")
    border.color: active ? Theme.colors.text : Theme.colors.border
    scale: ma.pressed ? 0.96 : 1

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on scale { NumberAnimation { duration: 80 } }

    Text {
        id: txt
        anchors.centerIn: parent
        text: chip.label
        color: chip.active ? Theme.colors.background : Theme.colors.textMuted
        font.pixelSize: Theme.font.sizeSmall + 1
        font.family: Theme.font.family
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: chip.clicked()
    }
}
