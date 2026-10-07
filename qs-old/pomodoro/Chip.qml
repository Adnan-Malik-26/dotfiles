import QtQuick

Rectangle {
    id: chip
    property string label
    property bool active: false
    property int padding: 24
    signal clicked()

    implicitWidth: txt.implicitWidth + padding
    implicitHeight: 30
    radius: height / 2
    color: active ? "#e8e8e8" : (ma.containsMouse ? "#1f1f1f" : "transparent")
    border.color: active ? "#e8e8e8" : "#2a2a2a"
    scale: ma.pressed ? 0.96 : 1

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on scale { NumberAnimation { duration: 80 } }

    Text {
        id: txt
        anchors.centerIn: parent
        text: chip.label
        color: chip.active ? "#0e0e0e" : "#b0b0b0"
        font.pixelSize: 12
        font.family: "monospace"
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: chip.clicked()
    }
}
