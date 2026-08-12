import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "config.js" as Config

// ============================================================================
// NotificationPopup
// One instance per entry in NotificationDaemon.popups (see Notifications.qml
// Variants block). Stacks below the previous popup using its index in the
// queue — cheap, but re-flows every popup's y-offset when one above it
// expires. Fine at toast-scale (few, short-lived); if you ever need N>10
// concurrent stacked toasts, replace this with a single PanelWindow + a
// ColumnLayout of cards instead of one window per notification.
// ============================================================================

PanelWindow {
    id: popup
    required property Notification notification

    readonly property int stackIndex: NotificationDaemon.popups.indexOf(notification)

    anchors { top: true; right: true }
    margins {
        top: Config.layout.margin + Math.max(0, stackIndex) * Config.layout.popupSpacing
        right: Config.layout.margin
    }
    implicitWidth: Config.layout.panelWidth
    implicitHeight: card.height + 16
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusiveZone: 0

    NotificationCard {
        id: card
        anchors.centerIn: parent
        width: parent.width - 16
        notification: popup.notification
    }
}
