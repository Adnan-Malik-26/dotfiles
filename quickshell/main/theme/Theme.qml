pragma Singleton

import QtQuick
import Quickshell

// ============================================================================
// Theme — the ONLY place colors, fonts, radii and motion are defined.
// Replaces both config.js copies (Notifications + Network). Everything visual
// reads `Theme.*`; module-specific tuning (scan intervals, history limit, OSD
// size...) lives with the module/service that owns it, not here.
// ============================================================================

Singleton {
    readonly property QtObject colors: QtObject {
        readonly property color background:   "#000000"
        readonly property color surface:      "#1a1a1a"
        readonly property color surfaceHover: "#2a2a2a"
        readonly property color border:       "#3a3a3a"

        readonly property color accent:       "#c3cadd"
        readonly property color accentAlt:    "#dac3dd"

        readonly property color danger:       "#e8b4b4"
        readonly property color success:      "#c4d6c4"
        readonly property color warning:      "#ded8b8"

        readonly property color text:         "#e6e6e6"
        readonly property color textMuted:    "#8a8a8a"

        readonly property color sliderTrack:  "#4a4a4a"
        readonly property color sliderFill:   "#c3cadd"

        readonly property color scrim:        "#66000000"   // dim backdrop behind modal overlays
    }

    readonly property QtObject font: QtObject {
        readonly property string family:     "JetBrainsMono Nerd Font"
        readonly property int    sizeSmall:  11
        readonly property int    sizeNormal: 13
        readonly property int    sizeLarge:  16
        readonly property int    weightBold: 600
    }

    readonly property QtObject layout: QtObject {
        readonly property int margin:            12
        readonly property int cardRadius:        12
        readonly property int rowRadius:         10
        readonly property int cardSpacing:       8
        readonly property int rowSpacing:        6
        readonly property int panelWidth:        380   // notification center + toasts
        readonly property int panelWidthCompact: 340   // wifi / bluetooth panels
    }

    readonly property int animation: 180   // ms, show/hide + hover transitions
}
