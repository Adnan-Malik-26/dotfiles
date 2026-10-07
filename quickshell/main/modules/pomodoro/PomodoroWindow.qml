import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"
import "../../services"
import "../../components"

// Centered overlay (layer-shell with no anchors). Keys: Space start/pause,
// Ctrl+R reset, Tab next tab, Esc leave a text field, then close.
PanelWindow {
    id: win

    property bool shown: false
    property string view: "timer"
    readonly property var views: ["timer", "history", "stats"]

    visible: shown
    implicitWidth: 420
    implicitHeight: 540
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "pomodoro"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    onVisibleChanged: if (visible) intro.restart()

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 18
        color: Theme.colors.background
        border.color: Theme.colors.border

        ParallelAnimation {
            id: intro
            NumberAnimation { target: card; property: "opacity"; from: 0; to: 1; duration: 180; easing.type: Easing.OutCubic }
            NumberAnimation { target: card; property: "scale"; from: 0.96; to: 1; duration: 220; easing.type: Easing.OutCubic }
        }

        // Space is not intercepted while you're typing in a field (Qt lets a
        // focused TextInput claim printable keys before shortcuts fire).
        Shortcut {
            sequence: "Escape"
            onActivated: timerView.typing ? card.forceActiveFocus() : win.shown = false
        }
        Shortcut { sequence: "Space"; onActivated: Pomodoro.toggle() }
        Shortcut { sequence: "Ctrl+R"; onActivated: Pomodoro.reset() }
        Shortcut {
            sequence: "Tab"
            onActivated: {
                card.forceActiveFocus()
                win.view = win.views[(win.views.indexOf(win.view) + 1) % win.views.length]
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Repeater {
                    model: win.views
                    Chip {
                        required property string modelData
                        label: modelData
                        active: win.view === modelData
                        onClicked: win.view = modelData
                    }
                }
                Item { Layout.fillWidth: true }
                Chip { label: "✕"; padding: 14; onClicked: win.shown = false }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                TimerView {
                    id: timerView
                    anchors.fill: parent
                    active: win.view === "timer"
                    onBlurRequested: card.forceActiveFocus()
                }
                HistoryView { anchors.fill: parent; active: win.view === "history" }
                StatsView { anchors.fill: parent; active: win.view === "stats" }
            }
        }
    }
}
