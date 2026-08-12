import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "config.js" as Config

RowLayout {
    id: root
    spacing: 8

    Text {
        text: "󰃠"
        color: Config.colors.text
        font.family: Config.font.family
        font.pixelSize: Config.font.sizeNormal + 6
        verticalAlignment: Text.AlignVCenter
    }

    Slider {
        id: slider
        Layout.fillWidth: true
        enabled: Brightness.ready
        from: 0.01; to: 1
        value: Brightness.value
        onMoved: Brightness.setBrightness(value)

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
        text: Brightness.ready ? Math.round(Brightness.value * 100) + "%" : "--"
        color: Config.colors.textMuted
        font.family: Config.font.family
        font.pixelSize: Config.font.sizeSmall
        Layout.preferredWidth: 34
    }
}
