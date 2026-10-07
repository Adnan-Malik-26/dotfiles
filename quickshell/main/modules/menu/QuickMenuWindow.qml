import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../components"

// Fullscreen transparent overlay with the card centered; click outside closes.
// All state/logic lives in QuickMenu (`menu`); this file is view only.
PanelWindow {
    id: win

    required property var menu

    function resetInput() { input.text = "" }
    function focusInput() { input.forceActiveFocus() }
    function ensureVisible(i) { list.positionViewAtIndex(i, ListView.Contain) }

    visible: menu.shown
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "menu"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    onVisibleChanged: {
        if (visible) {
            intro.restart();
            Qt.callLater(function () { input.forceActiveFocus(); });
        }
    }

    // click outside the card closes
    MouseArea {
        anchors.fill: parent
        onClicked: menu.shown = false
    }
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: Theme.colors.scrim
        z: -1
    }

    Rectangle {
        id: card
        width: 560
        height: 440
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
            anchors.margins: 16
            spacing: 12

            // mode chips
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Repeater {
                    model: menu.modes
                    Chip {
                        required property string modelData
                        label: modelData
                        active: menu.mode === modelData
                        onClicked: menu.setMode(modelData)
                    }
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: menu.results.length + (menu.results.length === 1 ? " result" : " results")
                    color: Theme.colors.sliderTrack
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.sizeSmall
                }
            }

            // search
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 42
                radius: Theme.layout.rowRadius
                color: Theme.colors.surface
                border.color: Theme.colors.border

                TextInput {
                    id: input
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.colors.text
                    font.family: Theme.font.family
                    font.pixelSize: 15
                    clip: true
                    focus: true
                    selectByMouse: true
                    onTextChanged: menu.query = text

                    Keys.onPressed: function (e) {
                        var ctrl = e.modifiers & Qt.ControlModifier;
                        if (e.key === Qt.Key_Escape) {
                            menu.shown = false; e.accepted = true;
                        } else if (e.key === Qt.Key_Down || (ctrl && (e.key === Qt.Key_N || e.key === Qt.Key_J))) {
                            menu.move(1); e.accepted = true;
                        } else if (e.key === Qt.Key_Up || (ctrl && (e.key === Qt.Key_P || e.key === Qt.Key_K))) {
                            menu.move(-1); e.accepted = true;
                        } else if (e.key === Qt.Key_Tab) {
                            menu.cycleMode(1); e.accepted = true;
                        } else if (e.key === Qt.Key_Backtab) {
                            menu.cycleMode(-1); e.accepted = true;
                        } else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                            menu.activate(); e.accepted = true;
                        } else if (ctrl && e.key === Qt.Key_W) {
                            var p = input.cursorPosition, t = input.text, i = p;
                            while (i > 0 && t.charAt(i - 1) === " ") i--;
                            while (i > 0 && t.charAt(i - 1) !== " ") i--;
                            input.remove(i, p);
                            e.accepted = true;
                        } else if (ctrl && e.key === Qt.Key_D && menu.mode === "clipboard") {
                            menu.deleteClip(); e.accepted = true;
                        }
                    }

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        visible: !input.text.length
                        text: menu.mode === "apps" ? "Search applications…"
                            : menu.mode === "clipboard" ? "Search clipboard…" : "Filter actions…"
                        color: Theme.colors.sliderTrack
                        font.family: Theme.font.family
                        font.pixelSize: 15
                    }
                }
            }

            // results
            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                model: menu.results
                currentIndex: menu.sel
                boundsBehavior: Flickable.StopAtBounds

                Text {
                    anchors.centerIn: parent
                    visible: menu.results.length === 0
                    horizontalAlignment: Text.AlignHCenter
                    text: menu.mode === "clipboard"
                        ? "no clipboard entries\nneeds: wl-paste --watch cliphist store"
                        : "no matches"
                    color: Theme.colors.sliderTrack
                    font.family: Theme.font.family
                    font.pixelSize: Theme.font.sizeSmall + 1
                }

                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    readonly property bool selected: index === menu.sel
                    readonly property bool isArmed: menu.armed === modelData.key

                    width: list.width
                    height: 46
                    radius: 9
                    color: isArmed ? Theme.colors.text : (selected ? Theme.colors.surface : "transparent")
                    border.color: selected && !isArmed ? Theme.colors.border : "transparent"
                    Behavior on color { ColorAnimation { duration: 90 } }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onPositionChanged: if (menu.sel !== row.index) menu.sel = row.index
                        onClicked: { menu.sel = row.index; menu.activate(); }
                    }

                    Column {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        anchors.topMargin: 6
                        spacing: 1
                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: row.isArmed ? "Press Enter again to confirm" : row.modelData.title
                            color: row.isArmed ? Theme.colors.background
                                 : (row.selected ? Theme.colors.text : Theme.colors.textMuted)
                            font.family: Theme.font.family
                            font.pixelSize: 14
                        }
                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            visible: text.length > 0 && !row.isArmed
                            text: row.modelData.sub || ""
                            color: Theme.colors.textMuted
                            font.family: Theme.font.family
                            font.pixelSize: Theme.font.sizeSmall
                        }
                    }
                }
            }

            // footer hints
            Text {
                Layout.fillWidth: true
                text: menu.mode === "clipboard" ? "↑↓ select · ⏎ copy · Ctrl+D delete · Tab mode · Esc close"
                    : menu.mode === "power" ? "↑↓ select · ⏎ run (twice for destructive) · Tab mode · Esc close"
                    : "↑↓ select · ⏎ launch · Tab mode · Esc close"
                color: Theme.colors.sliderTrack
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeSmall
            }
        }
    }
}
