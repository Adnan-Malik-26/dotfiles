import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"

// Fullscreen transparent overlay, card centered; click outside closes.
// View only — query/selection state and actions live in WallpaperPicker.
// Needs Qt 6.5+ (QtQuick.Effects, used to round the thumbnail corners).
PanelWindow {
    id: win

    required property var picker

    readonly property int thumbW: 260
    readonly property int thumbH: 146
    readonly property int thumbGap: 16

    function resetInput() { input.text = "" }
    function focusInput() { input.forceActiveFocus() }

    visible: picker.shown
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "wallpaper"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    onVisibleChanged: {
        if (visible) {
            intro.restart()
            Qt.callLater(win.focusInput)
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: picker.close()
    }
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Theme.colors.scrim
        z: -1
    }

    Rectangle {
        id: card
        width: 900
        height: 372
        anchors.centerIn: parent
        radius: 18
        color: Theme.colors.background
        border.color: Theme.colors.border

        ParallelAnimation {
            id: intro
            NumberAnimation { target: card; property: "opacity"; from: 0; to: 1; duration: 160; easing.type: Easing.OutCubic }
            NumberAnimation { target: card; property: "scale"; from: 0.97; to: 1; duration: 200; easing.type: Easing.OutCubic }
            NumberAnimation { target: backdrop; property: "opacity"; from: 0; to: 1; duration: 200 }
        }

        MouseArea { anchors.fill: parent }   // swallow clicks on the card

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            // ---------- search ----------
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 44
                radius: Theme.layout.rowRadius
                color: Theme.colors.surface
                border.color: input.activeFocus ? Theme.colors.sliderTrack : Theme.colors.border
                Behavior on border.color { ColorAnimation { duration: 120 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 12

                    TextInput {
                        id: input
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        color: Theme.colors.text
                        font.family: Theme.font.family
                        font.pixelSize: 15
                        clip: true
                        focus: true
                        selectByMouse: true
                        onTextChanged: picker.query = text

                        Keys.onPressed: function (e) {
                            var ctrl = e.modifiers & Qt.ControlModifier;
                            if (e.key === Qt.Key_Escape) {
                                picker.close(); e.accepted = true;
                            } else if (e.key === Qt.Key_Right || e.key === Qt.Key_Down
                                       || (ctrl && (e.key === Qt.Key_N || e.key === Qt.Key_J))) {
                                picker.move(1); e.accepted = true;
                            } else if (e.key === Qt.Key_Left || e.key === Qt.Key_Up
                                       || (ctrl && (e.key === Qt.Key_P || e.key === Qt.Key_K))) {
                                picker.move(-1); e.accepted = true;
                            } else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                                picker.activate(); e.accepted = true;
                            } else if (ctrl && e.key === Qt.Key_R) {
                                picker.randomize(); e.accepted = true;
                            } else if (ctrl && e.key === Qt.Key_W) {
                                var p = input.cursorPosition, t = input.text, i = p;
                                while (i > 0 && t.charAt(i - 1) === " ") i--;
                                while (i > 0 && t.charAt(i - 1) !== " ") i--;
                                input.remove(i, p);
                                e.accepted = true;
                            }
                        }

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            visible: !input.text.length
                            text: "Search wallpapers…"
                            color: Theme.colors.sliderTrack
                            font.family: Theme.font.family
                            font.pixelSize: 15
                        }
                    }

                    Text {
                        text: picker.results.length + " / " + Wallpapers.files.length
                        color: Theme.colors.textMuted
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.sizeSmall
                    }
                }
            }

            // ---------- carousel ----------
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: win.thumbH + 28

                // scroll wheel / touchpad swipe steps through the strip
                WheelHandler {
                    property real acc: 0
                    onWheel: function (e) {
                        acc += e.angleDelta.y !== 0 ? e.angleDelta.y : e.angleDelta.x;
                        while (acc >= 120) { picker.move(-1); acc -= 120; }
                        while (acc <= -120) { picker.move(1); acc += 120; }
                    }
                }

                ListView {
                    id: strip
                    anchors.fill: parent
                    orientation: ListView.Horizontal
                    interactive: false
                    clip: true
                    spacing: win.thumbGap
                    model: picker.results
                    currentIndex: picker.sel
                    highlightRangeMode: ListView.StrictlyEnforceRange
                    preferredHighlightBegin: width / 2 - win.thumbW / 2
                    preferredHighlightEnd: width / 2 + win.thumbW / 2
                    highlightMoveDuration: 260

                    delegate: Item {
                        id: cell
                        required property var modelData
                        required property int index
                        readonly property bool selected: index === picker.sel
                        readonly property bool inUse: Wallpapers.isCurrent(modelData.path)

                        width: win.thumbW
                        height: strip.height

                        Item {
                            id: body
                            anchors.centerIn: parent
                            width: win.thumbW
                            height: win.thumbH
                            scale: cell.selected ? 1.0 : 0.86
                            opacity: cell.selected ? 1.0 : 0.5
                            Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                            Behavior on opacity { NumberAnimation { duration: 220 } }

                            // placeholder shown until the (async) thumbnail is ready
                            Rectangle {
                                anchors.fill: parent
                                radius: 12
                                color: Theme.colors.surface
                            }

                            // thumbnail, decoded at ~2x display size and masked to rounded corners
                            Image {
                                id: img
                                anchors.fill: parent
                                visible: false
                                source: Wallpapers.fileUrl(cell.modelData.path)
                                asynchronous: true
                                fillMode: Image.PreserveAspectCrop
                                sourceSize.width: win.thumbW * 2
                            }
                            Item {
                                id: roundMask
                                anchors.fill: parent
                                visible: false
                                layer.enabled: true
                                Rectangle { anchors.fill: parent; radius: 12; color: "black" }
                            }
                            MultiEffect {
                                anchors.fill: parent
                                source: img
                                maskEnabled: true
                                maskSource: roundMask
                                opacity: img.status === Image.Ready ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: Theme.animation } }
                            }

                            // frame
                            Rectangle {
                                anchors.fill: parent
                                radius: 12
                                color: "transparent"
                                border.width: cell.selected ? 2 : 1
                                border.color: cell.selected ? Theme.colors.text : Theme.colors.border
                                Behavior on border.color { ColorAnimation { duration: 160 } }
                            }

                            // "in use" badge
                            Rectangle {
                                visible: cell.inUse
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.margins: 10
                                width: 10
                                height: 10
                                radius: 5
                                color: Theme.colors.accent
                                border.width: 1
                                border.color: Theme.colors.background
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: cell.selected ? picker.activate() : picker.select(cell.index)
                        }
                    }
                }

                // soft edge fades
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 80
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Theme.colors.background }
                        GradientStop { position: 1.0; color: Qt.alpha(Theme.colors.background, 0) }
                    }
                }
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 80
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Qt.alpha(Theme.colors.background, 0) }
                        GradientStop { position: 1.0; color: Theme.colors.background }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: picker.results.length === 0
                    horizontalAlignment: Text.AlignHCenter
                    text: Wallpapers.files.length === 0 ? "no images in\n" + Wallpapers.dir : "no matches"
                    color: Theme.colors.sliderTrack
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.sizeSmall + 1
                }
            }

            // ---------- footer ----------
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                Text {
                    Layout.fillWidth: true
                    elide: Text.ElideMiddle
                    text: picker.selectedName + (picker.selected && Wallpapers.isCurrent(picker.selected.path) ? "  ·  in use" : "")
                    color: Theme.colors.text
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.sizeSmall + 1
                }
                Text {
                    text: "←→ ^N ^P move · ⏎ set · ^R random · Esc close"
                    color: Theme.colors.sliderTrack
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.sizeSmall
                }
            }
        }
    }
}
