pragma Singleton

import QtQuick
import Quickshell

// Shared wall clock. Minute precision = one wakeup per minute.
Singleton {
    readonly property date date: sys.date
    SystemClock { id: sys; precision: SystemClock.Minutes }
}
