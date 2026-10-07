import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../../services"
import "../../components"

Item {
    id: root
    property bool active: false
    readonly property bool typing: tagIn.activeFocus || minIn.activeFocus
    signal blurRequested()

    visible: opacity > 0
    opacity: active ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: Theme.animation } }

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        // progress ring + time
        Item {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 230
            implicitHeight: 230

            Canvas {
                id: ring
                anchors.fill: parent
                property real p: Pomodoro.total > 0 ? 1 - Pomodoro.remaining / Pomodoro.total : 0
                Behavior on p { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                onPChanged: requestPaint()
                onPaint: {
                    var c = getContext("2d");
                    c.reset();
                    var r = width / 2 - 8, cx = width / 2, cy = height / 2;
                    c.lineWidth = 4;
                    c.lineCap = "round";
                    c.strokeStyle = Theme.colors.border;
                    c.beginPath(); c.arc(cx, cy, r, 0, 2 * Math.PI); c.stroke();
                    if (p > 0) {
                        c.strokeStyle = Theme.colors.text;
                        c.beginPath();
                        c.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + 2 * Math.PI * p);
                        c.stroke();
                    }
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 4
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Pomodoro.fmtClock(Pomodoro.remaining)
                    color: Theme.colors.text
                    font.pixelSize: 48
                    font.family: Theme.font.family
                    font.weight: Font.Light
                    opacity: Pomodoro.running ? 1 : 0.6
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Pomodoro.tag.trim() === "" ? "untagged" : Pomodoro.tag
                    color: Theme.colors.textMuted
                    font.pixelSize: Theme.font.sizeSmall + 1
                    font.family: Theme.font.family
                }
            }
        }

        // presets + custom length
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8
            Repeater {
                model: [5, 15, 25, 50]
                Chip {
                    required property int modelData
                    label: modelData + "m"
                    active: Pomodoro.minutes === modelData
                    onClicked: Pomodoro.setMinutes(modelData)
                }
            }
            Rectangle {
                implicitWidth: 64
                implicitHeight: 30
                radius: 15
                color: Theme.colors.surface
                border.color: minIn.activeFocus ? Theme.colors.sliderTrack : Theme.colors.border
                TextInput {
                    id: minIn
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: TextInput.AlignVCenter
                    horizontalAlignment: TextInput.AlignHCenter
                    color: Theme.colors.text
                    font.pixelSize: Theme.font.sizeSmall + 1
                    font.family: Theme.font.family
                    validator: IntValidator { bottom: 1; top: 240 }
                    selectByMouse: true
                    onAccepted: { Pomodoro.setMinutes(parseInt(text)); text = ""; root.blurRequested() }
                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        visible: !minIn.text.length
                        text: "custom"
                        color: Theme.colors.sliderTrack
                        font.pixelSize: Theme.font.sizeSmall
                        font.family: Theme.font.family
                    }
                }
            }
        }

        // tag input
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 36
            radius: 8
            color: Theme.colors.surface
            border.color: tagIn.activeFocus ? Theme.colors.sliderTrack : Theme.colors.border
            Behavior on border.color { ColorAnimation { duration: 120 } }
            TextInput {
                id: tagIn
                anchors.fill: parent
                anchors.margins: 10
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.colors.text
                font.pixelSize: Theme.font.sizeNormal
                font.family: Theme.font.family
                clip: true
                selectByMouse: true
                Component.onCompleted: text = Pomodoro.tag
                onTextEdited: Pomodoro.tag = text
                onAccepted: root.blurRequested()
                Connections {
                    target: Pomodoro
                    function onTagChanged() { if (tagIn.text !== Pomodoro.tag) tagIn.text = Pomodoro.tag }
                }
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    visible: !tagIn.text.length
                    text: "tag (e.g. rust, dsa)"
                    color: Theme.colors.sliderTrack
                    font.pixelSize: Theme.font.sizeNormal
                    font.family: Theme.font.family
                }
            }
        }

        // recent tags
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Repeater {
                model: Pomodoro.recent
                Chip {
                    required property string modelData
                    label: modelData
                    active: Pomodoro.tag === modelData
                    onClicked: Pomodoro.tag = modelData
                }
            }
            Item { Layout.fillWidth: true }
        }

        Item { Layout.fillHeight: true }

        // controls
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            Chip {
                implicitWidth: 120
                implicitHeight: 40
                label: Pomodoro.running ? "pause" : "start"
                active: true
                onClicked: Pomodoro.toggle()
            }
            Chip {
                implicitWidth: 90
                implicitHeight: 40
                label: "reset"
                onClicked: Pomodoro.reset()
            }
        }
    }
}
