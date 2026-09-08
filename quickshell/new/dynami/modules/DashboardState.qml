pragma Singleton
import QtQuick

// Single source of truth for expanded/collapsed state.
// Both Island.qml (writer, on click) and Dashboard.qml (reader + writer,
// on Escape) bind to this instead of exposing a property on one window
// that the other has to reach into — avoids binding-loop footguns when
// two separate PanelWindow instances both need to mutate the same state.
QtObject {
    property bool open: false
}
