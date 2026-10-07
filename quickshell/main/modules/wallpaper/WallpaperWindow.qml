import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"

// Fullscreen transparent overlay, card centered; click outside closes.
// View only — selection state and actions live in WallpaperPicker (`picker`).
PanelWindow {
    id: win

    required property var picker

    function ensureVisible(i) { grid.positionViewAtIndex(i, GridView.Contain) }
    function focusKeys() { keys.forceActiveFocus() }

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
            Qt.callLater(win.focusKeys)
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
        width: 756
        height: 560
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

        FocusScope {
            id: keys
            anchors.fill: parent
            focus: true

            Keys.onPressed: function (e) {
                var cols = Math.max(1, Math.floor(grid.width / grid.cellWidth));
                switch (e.key) {
                case Qt.Key_Escape: picker.close(); break;
                case Qt.Key_Left:
                case Qt.Key_H: picker.move(-1); break;
                case Qt.Key_Right:
                case Qt.Key_L: picker.move(1); break;
                case Qt.Key_Up:
                case Qt.Key_K: picker.move(-cols); break;
                case Qt.Key_Down:
                case Qt.Key_J: picker.move(cols); break;
                case Qt.Key_Return:
                case Qt.Key_Enter: picker.activate(); break;
                case Qt.Key_R: picker.randomize(); break;
                default: return;
                }
                e.accepted = true;
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 12

                // header
                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Wallpapers"
                        color: Theme.colors.text
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.sizeLarge
                        font.weight: Theme.font.weightBold
                        Layout.fillWidth: true
                    }
                    Text {
                        text: Wallpapers.files.length + (Wallpapers.files.length === 1 ? " image" : " images")
                        color: Theme.colors.textMuted
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.sizeSmall
                    }
                }

                // thumbnails
                GridView {
                    id: grid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    cellWidth: 236
                    cellHeight: 142
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    model: Wallpapers.files
                    currentIndex: picker.sel

                    Text {
                        anchors.centerIn: parent
                        visible: Wallpapers.files.length === 0
                        horizontalAlignment: Text.AlignHCenter
                        text: "no images in\n" + Wallpapers.dir
                        color: Theme.colors.sliderTrack
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.sizeSmall + 1
                    }

                    delegate: Item {
                        id: cell
                        required property var modelData
                        required property int index
                        readonly property bool selected: index === picker.sel
                        readonly property bool isCurrent: Wallpapers.isCurrent(modelData.path)

                        width: grid.cellWidth
                        height: grid.cellHeight

                        // placeholder behind the (async) thumbnail
                        Rectangle {
                            x: 8; y: 9
                            width: 220; height: 124
                            radius: 6
                            color: Theme.colors.surface

                            Image {
                                anchors.fill: parent
                                anchors.margins: 2
                                source: Wallpapers.fileUrl(cell.modelData.path)
                                asynchronous: true
                                fillMode: Image.PreserveAspectCrop
                                sourceSize.width: 440          // decode at ~2x the display size, not full resolution
                                opacity: status === Image.Ready ? 1 : 0
                                Behavior on opacity { NumberAnimation { duration: Theme.animation } }
                            }

                            // selection / hover frame drawn on top
                            Rectangle {
                                anchors.fill: parent
                                radius: 6
                                color: "transparent"
                                border.width: cell.selected ? 2 : 1
                                border.color: cell.selected ? Theme.colors.text : Theme.colors.border
                            }

                            // "in use" badge
                            Rectangle {
                                visible: cell.isCurrent
                                anchors.top: parent.top
                                anchors.right: parent.right
                                anchors.margins: 8
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
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onPositionChanged: if (picker.sel !== cell.index) picker.sel = cell.index
                            onClicked: { picker.sel = cell.index; picker.activate(); }
                        }
                    }
                }

                // footer
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Text {
                        Layout.fillWidth: true
                        elide: Text.ElideMiddle
                        text: picker.selectedName
                        color: Theme.colors.textMuted
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.sizeSmall
                    }
                    Text {
                        text: "←↑↓→ move · ⏎ set · R random · Esc close"
                        color: Theme.colors.sliderTrack
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.sizeSmall
                    }
                }
            }
        }
    }
}
