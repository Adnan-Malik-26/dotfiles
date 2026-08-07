import QtQuick
import Quickshell
import Quickshell.Wayland
import "../colors" as C

// Always-on-top, always-visible layer-shell panel anchored top-center.
// This IS the dynamic island. It never resizes itself — the Dashboard
// is a *separate* panel window that toggles visibility, layered above it.
// Trying to animate this window's own size for the expanded state fights
// the compositor's layer-shell geometry on every Hyprland/Sway build;
// two windows is the pattern every working dynamic-island rice uses.
PanelWindow {
    id: island

    screen: Quickshell.screens[0]
    anchors {
        top: true
    }
    margins.top: 8

    implicitWidth: pill.implicitWidth
    implicitHeight: pill.implicitHeight

    color: "transparent"

    // Layer-shell: sits above normal windows, doesn't take input focus
    // away from your active app, doesn't appear in the taskbar.
    WlrLayershell.layer: WlrLayer.Overlay
    // WlrLayershell.exclusiveZone: -1 // don't reserve space / shove other bars
    WlrLayershell.namespace: "quickshell:island"

    Rectangle {
        id: pill
        anchors.centerIn: parent
        implicitWidth: clockRow.implicitWidth + 28
        implicitHeight: clockRow.implicitHeight + 14
        radius: height / 2
        color: C.Palette.bg
        border.color: mouseArea.containsMouse ? C.Palette.accent : C.Palette.border
        border.width: 1

        Behavior on border.color { ColorAnimation { duration: 150 } }

        // subtle scale-in on hover, this is what sells "island" over "bar"
        scale: mouseArea.containsMouse ? 1.04 : 1.0
        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

        Row {
            id: clockRow
            anchors.centerIn: parent
            spacing: 6

            Rectangle {
                width: 6; height: 6; radius: 3
                anchors.verticalCenter: parent.verticalCenter
                color: C.Palette.accent
            }

            Text {
                id: clockText
                anchors.verticalCenter: parent.verticalCenter
                text: Qt.formatTime(clock.date, "hh:mm")
                color: C.Palette.text
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
                font.weight: Font.Medium
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: DashboardState.open = !DashboardState.open
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
