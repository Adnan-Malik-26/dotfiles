import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../theme"
import "../../services"

RowLayout {
    id: root
    spacing: 8

    Text {
        text: Audio.muted ? "󰕟" : "󰕾"
        color: Theme.colors.text
        font.family: Theme.font.family
        font.pixelSize: Theme.font.sizeNormal + 6
        verticalAlignment: Text.AlignVCenter

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Audio.toggleMute()
        }
    }

    Slider {
        id: slider
        Layout.fillWidth: true
        enabled: Audio.ready
        from: 0; to: 1
        value: Audio.volume
        onMoved: Audio.setVolume(value)

        background: Rectangle {
            x: slider.leftPadding
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            width: slider.availableWidth
            height: 6
            radius: 3
            color: Theme.colors.sliderTrack

            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                radius: 3
                color: Theme.colors.sliderFill
            }
        }
    }

    Text {
        text: Audio.ready ? Math.round(Audio.volume * 100) + "%" : "--"
        color: Theme.colors.textMuted
        font.family: Theme.font.family
        font.pixelSize: Theme.font.sizeSmall
        Layout.preferredWidth: 34
    }
}
