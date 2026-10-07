import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Mpris
import "../../theme"

Rectangle {
    id: root
    radius: Theme.layout.cardRadius
    color: Theme.colors.surface
    Layout.preferredHeight: player ? 84 : 0
    visible: player !== null
    clip: true

    Behavior on Layout.preferredHeight { NumberAnimation { duration: Theme.animation } }

    // Prefer an actively playing player; fall back to the first available one
    // so paused sessions (e.g. you tabbed away) still show controls.
    readonly property var player: {
        const list = Mpris.players.values
        for (const p of list) {
            if (p.playbackState === MprisPlaybackState.Playing) return p
        }
        return list.length > 0 ? list[0] : null
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 56
            Layout.preferredHeight: 56
            radius: 8
            color: Theme.colors.surfaceHover
            clip: true

            Image {
                anchors.fill: parent
                visible: root.player && root.player.trackArtUrl !== ""
                source: root.player ? root.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: root.player ? (root.player.trackTitle || "Unknown track") : ""
                color: Theme.colors.text
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeNormal
                font.weight: Theme.font.weightBold
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            Text {
                text: root.player ? (root.player.trackArtist || "") : ""
                color: Theme.colors.textMuted
                font.family: Theme.font.family
                font.pixelSize: Theme.font.sizeSmall
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 4

                Button {
                    id: prevBtn
                    flat: true
                    enabled: root.player && root.player.canGoPrevious
                    onClicked: root.player.previous()

                    contentItem: Text {
                        text: "󰒮"
                        color: prevBtn.enabled ? Theme.colors.accentAlt : Theme.colors.textMuted
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.sizeNormal + 6
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: 6
                        color: prevBtn.hovered ? Theme.colors.surfaceHover : "transparent"
                    }
                }

                Button {
                    id: playBtn
                    flat: true
                    enabled: root.player && root.player.canTogglePlaying
                    onClicked: root.player.togglePlaying()

                    readonly property bool playing: root.player && root.player.playbackState === MprisPlaybackState.Playing

                    contentItem: Text {
                        text: playBtn.playing ? "󰏤" : "󰐊"
                        color: playBtn.enabled ? Theme.colors.accentAlt : Theme.colors.textMuted
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.sizeNormal + 8
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: 6
                        color: playBtn.hovered ? Theme.colors.surfaceHover : "transparent"
                    }
                }

                Button {
                    id: nextBtn
                    flat: true
                    enabled: root.player && root.player.canGoNext
                    onClicked: root.player.next()

                    contentItem: Text {
                        text: "󰒭"
                        color: nextBtn.enabled ? Theme.colors.accentAlt : Theme.colors.textMuted
                        font.family: Theme.font.family
                        font.pixelSize: Theme.font.sizeNormal + 6
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: 6
                        color: nextBtn.hovered ? Theme.colors.surfaceHover : "transparent"
                    }
                }
            }
        }
    }
}
