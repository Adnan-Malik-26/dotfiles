.pragma library

// ============================================================================
// Notification Center — Config
// Edit ONLY this file to reskin/retime the whole module. Every component
// imports it as `import "config.js" as Config` and reads from it directly —
// no cached copies, no prop-drilling.
// ============================================================================

const colors = {

    background:    "#000000",  // Black

    surface:       "#1a1a1a",  // Charcoal
    surfaceHover:  "#2a2a2a",  // Graphite

    border:        "#3a3a3a",  // Slate

    accent:        "#c3cadd",  // Blue
    accentAlt:     "#dac3dd",  // Purple

    danger:        "#e8b4b4",  // Red
    success:       "#c4d6c4",  // Green
    warning:       "#ded8b8",  // Yellow

    text:          "#e6e6e6",  // White
    textMuted:     "#8a8a8a",  // Ash

    sliderTrack:   "#4a4a4a",  // Gray
    sliderFill:    "#c3cadd"   // Blue

}

const font = {
    family:      "JetBrainsMono Nerd Font",
    sizeSmall:   11,
    sizeNormal:  13,
    sizeLarge:   16,
    weightBold:  600
}

const timeout = {
    popupDefault:  5000,  // ms a Normal-urgency toast stays visible
    popupLow:      3000,
    popupCritical: 0,     // 0 = sticky, requires explicit dismiss
    osd:           1800,  // ms the OSD stays visible after a change
    animation:     180    // ms for show/hide transitions
}

const layout = {
    panelWidth:   380,
    cardRadius:   12,
    cardSpacing:  8,
    margin:       12,
    osdWidth:     260,
    osdHeight:    64,
    popupSpacing: 90   // vertical offset between stacked toast popups
}

const history = {
    limit:     50,
    statePath: "$HOME/.local/state/quickshell/notifications.json"
}

// NotificationUrgency: Low = 0, Normal = 1, Critical = 2
function urgencyTimeout(urgency) {
    if (urgency === 2) return timeout.popupCritical
    if (urgency === 0) return timeout.popupLow
    return timeout.popupDefault
}
