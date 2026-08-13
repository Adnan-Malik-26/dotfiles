.pragma library

// ============================================================================
// Network (WiFi + Bluetooth) — Config
// Same shape as Notifications/config.js on purpose: if you ever centralize
// theming, both modules can import one shared file without touching call
// sites — every component here reads `Config.colors.x`, never a literal.
// Edit ONLY this file to reskin/retime the whole module.
// ============================================================================

const colors = {

    background:    "#000000",
    surface:       "#1a1a1a",
    surfaceHover:  "#2a2a2a",

    border:        "#3a3a3a",

    accent:        "#c3cadd",
    accentAlt:     "#dac3dd",

    danger:        "#e8b4b4",
    success:       "#c4d6c4",
    warning:       "#ded8b8",

    text:          "#e6e6e6",
    textMuted:     "#8a8a8a",

    sliderTrack:   "#4a4a4a",
    sliderFill:    "#c3cadd"

}

const font = {
    family:      "JetBrainsMono Nerd Font",
    sizeSmall:   11,
    sizeNormal:  13,
    sizeLarge:   16,
    weightBold:  600
}

const timeout = {
    animation:      180,   // ms for show/hide + hover transitions
    scanInterval:   10000, // ms between passive WiFi list refreshes
    scanBurst:      15000, // ms an active WiFi rescan / BT discovery stays on
    connectTimeout: 15000  // ms before a stuck "Connecting..." resets itself
}

const layout = {
    panelWidth:   340,
    cardRadius:   12,
    rowRadius:    10,
    rowSpacing:   6,
    margin:       12,
    // WiFi and Bluetooth panels anchor at different right-margins so they
    // can both be open at once without stacking on top of each other.
    wifiRightMargin:      12,
    bluetoothRightMargin: 368
}
