import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import "../colors" as C

// Expanded panel. Visibility is driven externally (bound to Island.dashboardOpen)
// so there's exactly one source of truth for open/closed state.
PanelWindow {
    id: dashboard

    property bool open: DashboardState.open
    visible: open

    screen: Quickshell.screens[0]
    anchors { top: true }
    margins.top: 56 // sits just under the island pill

    implicitWidth: 360
    implicitHeight: content.implicitHeight + 32

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.namespace: "quickshell:island-dashboard"
    // Take keyboard/pointer input only while open, so it doesn't eat
    // clicks on your desktop when collapsed.
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 20
        color: C.Palette.bg
        border.color: C.Palette.border
        border.width: 1

        opacity: dashboard.open ? 1 : 0
        scale: dashboard.open ? 1 : 0.92
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutQuad } }
        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // --- Big clock + full date ---
            ColumnLayout {
                spacing: 2
                Text {
                    text: Qt.formatTime(sysClock.date, "hh:mm:ss")
                    color: C.Palette.text
                    font.pixelSize: 36
                    font.weight: Font.DemiBold
                    font.family: "JetBrainsMono Nerd Font"
                }
                Text {
                    text: Qt.formatDate(sysClock.date, "dddd, d MMMM yyyy")
                    color: C.Palette.subtext
                    font.pixelSize: 14
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: C.Palette.border }

            // --- Now playing (MPRIS) ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: Mpris.players.count > 0

                Rectangle {
                    width: 44; height: 44; radius: 10
                    color: C.Palette.surface
                    Text {
                        anchors.centerIn: parent
                        text: activePlayer && activePlayer.isPlaying ? "\u25B6" : "\u23F8"
                        color: C.Palette.accent
                        font.pixelSize: 16
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        text: activePlayer ? (activePlayer.trackTitle || "Unknown track") : ""
                        color: C.Palette.text
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }
                    Text {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        text: activePlayer ? (activePlayer.trackArtist || "") : ""
                        color: C.Palette.subtext
                        font.pixelSize: 12
                    }
                }
            }

            Text {
                visible: Mpris.players.count === 0
                text: "Nothing playing"
                color: C.Palette.subtext
                font.pixelSize: 13
                font.italic: true
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: C.Palette.border }

            // --- CPU ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "CPU"; color: C.Palette.subtext; font.pixelSize: 12 }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: Math.round(SystemStats.cpuUsage * 100) + "%"
                        color: C.Palette.loadColor(SystemStats.cpuUsage)
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: C.Palette.surface
                    Rectangle {
                        width: parent.width * SystemStats.cpuUsage
                        height: parent.height
                        radius: 3
                        color: C.Palette.loadColor(SystemStats.cpuUsage)
                        Behavior on width { NumberAnimation { duration: 300 } }
                    }
                }
            }

            // --- Memory ---
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "MEMORY"; color: C.Palette.subtext; font.pixelSize: 12 }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: SystemStats.memUsedGb.toFixed(1) + " / " + SystemStats.memTotalGb.toFixed(1) + " GB"
                        color: C.Palette.loadColor(SystemStats.memUsage)
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: C.Palette.surface
                    Rectangle {
                        width: parent.width * SystemStats.memUsage
                        height: parent.height
                        radius: 3
                        color: C.Palette.loadColor(SystemStats.memUsage)
                        Behavior on width { NumberAnimation { duration: 300 } }
                    }
                }
            }
        }
    }

    SystemClock {
        id: sysClock
        precision: SystemClock.Seconds
    }

    readonly property var activePlayer: Mpris.players.count > 0 ? Mpris.players.values[0] : null

    // Click-outside-to-close: a full-screen transparent catcher behind the
    // card would need its own layer below Overlay; simplest robust option
    // is closing on re-click of the island pill (already wired in Island.qml)
    // plus an Escape key while focused.
    Item {
        anchors.fill: parent
        focus: dashboard.open
        Keys.onEscapePressed: DashboardState.open = false
    }
}
