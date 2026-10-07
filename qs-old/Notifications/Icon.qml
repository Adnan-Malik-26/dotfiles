import QtQuick
import Quickshell
import Quickshell.Widgets
import Qt5Compat.GraphicalEffects

// ============================================================================
// Icon
// Real icon-theme lookup instead of hardcoded font glyphs — resolves `name`
// against the user's installed XDG icon theme (Quickshell.iconPath), falling
// back to `fallback` if the primary name isn't present in that theme, then
// recolors the (usually flat gray) symbolic SVG via ColorOverlay so it still
// respects config.js instead of looking theme-default everywhere.
//
// Requires: an icon theme with freedesktop symbolic icon names (Papirus,
// Adwaita, Breeze all ship these), and the qt6-5compat package for
// Qt5Compat.GraphicalEffects.
// ============================================================================

Item {
    id: root

    property string name: ""
    property string fallback: ""
    property color color: "white"
    property real size: 18

    implicitWidth: size
    implicitHeight: size

    IconImage {
        id: img
        anchors.fill: parent
        source: Quickshell.iconPath(root.name, root.fallback)
    }

    ColorOverlay {
        anchors.fill: img
        source: img
        color: root.color
    }
}
