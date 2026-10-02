import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import "config.js" as Config

// ============================================================================
// Bar — Minimal top bar
//
// Run standalone:      qs -c Bar
// Hyprland autostart:  exec-once = qs -c Bar
//
// Interactions:
//   - Arch logo (left)  → qs ipc call notifications toggle
//   - WiFi icon (right) → qs ipc call network toggleWifi
// ============================================================================

ShellRoot {
    id: root

    // ── PipeWire volume tracking ──────────────────────────────────────────
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false

    // ── Battery tracking via /sys ─────────────────────────────────────────
    property int batteryPercent: 100
    property string batteryStatus: "Full"

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: batteryProc.running = true
    }
    Component.onCompleted: batteryProc.running = true

    Process {
        id: batteryProc
        command: ["bash", "-c",
            "echo \"$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo -1):$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo Unknown)\""
        ]
        stdout: SplitParser {
            onRead: line => {
                const parts = line.split(":")
                if (parts.length >= 2) {
                    const v = parseInt(parts[0])
                    if (v >= 0) root.batteryPercent = v
                    root.batteryStatus = parts[1].trim()
                }
            }
        }
    }

    // ── IPC processes ─────────────────────────────────────────────────────
    Process { id: notifToggle; command: ["qs", "ipc", "call", "notifications", "toggle"] }
    Process { id: netToggle;   command: ["qs", "ipc", "call", "network", "toggleWifi"] }

    // ── The bar itself ────────────────────────────────────────────────────
    PanelWindow {
        id: bar

        anchors {
            top: true
            left: true
            right: true
        }
        height: 40
        color: "transparent"
        exclusionMode: ExclusionMode.Auto

        WlrLayershell.namespace: "bar"
        WlrLayershell.layer: WlrLayer.Top

        Item {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            // ── Left Section ──────────────────────────────────────────────
            RowLayout {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 14

                // Arch logo → open notification center
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: archMouse.containsMouse ? Config.colors.surfaceHover : "transparent"

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "\uf303"   // Arch Linux logo (Nerd Font)
                        font.family: Config.font.family
                        font.pixelSize: 18
                        color: Config.colors.accent
                    }
                    MouseArea {
                        id: archMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: notifToggle.running = true
                    }
                }

                Text {
                    text: "English"
                    font.family: Config.font.family
                    font.pixelSize: Config.font.sizeSmall
                    color: Config.colors.textMuted
                }

                Text {
                    text: "\udb80\udd0c"   // Keyboard icon (Nerd Font)
                    font.family: Config.font.family
                    font.pixelSize: Config.font.sizeSmall
                    color: Config.colors.textMuted
                }
            }

            // ── Center Section — floating tab ─────────────────────────────
            // A tab shape: rounded top corners, flat bottom, sitting on the
            // bar baseline so it looks like it extends upward from it.
            Rectangle {
                id: centerTab
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                width: centerLayout.width + 40
                height: 32
                color: Config.colors.surface
                border.color: Config.colors.border
                border.width: 1

                // Only round the top corners to create the "tab" shape
                radius: 10

                // Flat-bottom mask: a rectangle that covers the bottom
                // rounded corners so they appear flat/square
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: parent.radius
                    color: parent.color
                    border.color: Config.colors.border
                    border.width: 1

                    // Cover the top border of this mask rect so only the
                    // parent's top border shows
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 1
                        anchors.rightMargin: 1
                        height: 2
                        color: Config.colors.surface
                    }
                    // Cover the bottom border (it sits flush with bar bottom)
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 1
                        color: Config.colors.surface
                    }
                }

                RowLayout {
                    id: centerLayout
                    anchors.centerIn: parent
                    spacing: 18

                    // Clock
                    Text {
                        id: clockText
                        font.family: Config.font.family
                        font.pixelSize: Config.font.sizeNormal
                        font.weight: Font.DemiBold
                        color: Config.colors.text

                        Timer {
                            interval: 1000
                            running: true
                            repeat: true
                            onTriggered: clockText.text = Qt.formatTime(new Date(), "HH:mm:ss")
                        }
                        Component.onCompleted: text = Qt.formatTime(new Date(), "HH:mm:ss")
                    }

                    // Separator
                    Rectangle {
                        width: 1
                        height: 14
                        color: Config.colors.border
                        Layout.alignment: Qt.AlignVCenter
                    }

                    // Battery
                    RowLayout {
                        spacing: 5

                        Text {
                            text: {
                                if (root.batteryStatus === "Charging") return "\udb80\udc84"  // charging icon
                                if (root.batteryPercent > 90) return "\udb80\udc79"   // full
                                if (root.batteryPercent > 60) return "\udb80\udc7e"   // 3/4
                                if (root.batteryPercent > 30) return "\udb80\udc7c"   // half
                                if (root.batteryPercent > 10) return "\udb80\udc7a"   // low
                                return "\udb80\udc7b"                                   // critical
                            }
                            font.family: Config.font.family
                            font.pixelSize: Config.font.sizeNormal
                            color: root.batteryPercent <= 10 ? Config.colors.danger : Config.colors.text
                        }
                        Text {
                            text: root.batteryPercent + "%"
                            font.family: Config.font.family
                            font.pixelSize: Config.font.sizeSmall
                            font.weight: Font.DemiBold
                            color: root.batteryPercent <= 10 ? Config.colors.danger : Config.colors.text
                        }
                    }
                }
            }

            // ── Right Section ─────────────────────────────────────────────
            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 16

                // Volume — dynamic from PipeWire
                RowLayout {
                    spacing: 6
                    Text {
                        text: {
                            if (root.muted) return "\udb81\udd81"          // muted
                            if (root.volume > 0.66) return "\udb81\udd7e"  // high
                            if (root.volume > 0.33) return "\udb81\udd80"  // medium
                            return "\udb81\udd7f"                           // low
                        }
                        font.family: Config.font.family
                        font.pixelSize: Config.font.sizeNormal
                        color: root.muted ? Config.colors.danger : Config.colors.textMuted
                    }
                    Text {
                        text: root.muted ? "Mute" : Math.round(root.volume * 100) + "%"
                        font.family: Config.font.family
                        font.pixelSize: Config.font.sizeSmall
                        font.weight: Font.DemiBold
                        color: root.muted ? Config.colors.danger : Config.colors.textMuted
                    }
                }

                // WiFi icon → open network popup
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: wifiMouse.containsMouse ? Config.colors.surfaceHover : "transparent"

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "\udb80\udf2f"   // WiFi icon (Nerd Font)
                        font.family: Config.font.family
                        font.pixelSize: Config.font.sizeNormal
                        color: Config.colors.textMuted
                    }
                    MouseArea {
                        id: wifiMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: netToggle.running = true
                    }
                }
            }
        }
    }
}
