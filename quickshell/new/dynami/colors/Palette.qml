pragma Singleton
import QtQuick

// Mono Pastel — matches your existing Waybar/Kitty/Neovim palette.
// Swap these hex values for your actual theme tokens if they differ.
QtObject {
    readonly property color bg:        "#000000"   // island/dashboard background (with alpha)
    readonly property color bgSolid:   "#1e1e1e"
    readonly property color surface:   "#2c2c2c"
    readonly property color text:      "#e6e6e6"
    readonly property color subtext:   "#b5b5b5"
    readonly property color accent:    "#c3cadd"      // pastel lavender accent
    readonly property color accentDim: "#aeb7cc"
    readonly property color good:      "#c4d6c4"      // low load
    readonly property color warn:      "#ded8b8"      // mid load
    readonly property color crit:      "#e8b5b5"      // high load
    readonly property color border:    "#1c1c1c"

    function loadColor(pct) {
        if (pct < 0.5) return good
        if (pct < 0.8) return warn
        return crit
    }
}
