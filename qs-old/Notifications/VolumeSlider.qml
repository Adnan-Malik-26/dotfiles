import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "config.js" as Config

RowLayout {
    id: root
    spacing: 8

    Text {
        text: Audio.muted ? "󰕟" : "󰕾"
        color: Config.colors.text
        font.family: Config.font.family
        font.pixelSize: Config.font.sizeNormal + 6
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
            color: Config.colors.sliderTrack

            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                radius: 3
                color: Config.colors.sliderFill
            }
        }
    }

    Text {
        text: Audio.ready ? Math.round(Audio.volume * 100) + "%" : "--"
        color: Config.colors.textMuted
        font.family: Config.font.family
        font.pixelSize: Config.font.sizeSmall
        Layout.preferredWidth: 34
    }
}
