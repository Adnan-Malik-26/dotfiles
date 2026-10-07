import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    SystemClock {
        id: clock
        precision: SystemClock.Minutes   // use SystemClock.Seconds if you add :ss
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            // ---------- config ----------
            readonly property int barHeight: 32
            readonly property int triggerHeight: 2
            readonly property int firstDay: 1          // 0 = Sunday first, 1 = Monday first
            readonly property int calWidth: 270
            readonly property int calHeight: 272
            readonly property string fontFamily: "JetBrainsMono Nerd Font"

            // ---------- state ----------
            property bool revealed: false
            property bool calOpen: false
            property int viewYear: 2000
            property int viewMonth: 0

            readonly property int offset: (new Date(viewYear, viewMonth, 1).getDay() - firstDay + 7) % 7
            readonly property int daysInMonth: new Date(viewYear, viewMonth + 1, 0).getDate()
            readonly property var weekdays: {
                var names = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"], out = [];
                for (var i = 0; i < 7; i++) out.push(names[(i + firstDay) % 7]);
                return out;
            }

            function openCalendar() {
                var d = clock.date;
                viewYear = d.getFullYear();
                viewMonth = d.getMonth();
                calOpen = true;
            }
            function shiftMonth(delta) {
                var d = new Date(viewYear, viewMonth + delta, 1);
                viewYear = d.getFullYear();
                viewMonth = d.getMonth();
            }

            anchors { top: true; left: true; right: true }
            implicitHeight: barHeight + calHeight + 8
            color: "transparent"

            // Space is only reserved for the bar itself; the calendar overlays windows.
            exclusionMode: ExclusionMode.Normal
            exclusiveZone: revealed ? barHeight : 0
            WlrLayershell.namespace: "hoverclock"

            // Input region: thin strip when hidden, bar (+ calendar) when revealed.
            mask: Region { item: win.revealed ? panel : strip }

            Item {
                anchors.fill: parent

                Item {
                    id: strip
                    anchors.top: parent.top
                    width: parent.width
                    height: win.triggerHeight
                }

                Item {
                    id: panel
                    anchors.top: parent.top
                    width: parent.width
                    height: win.calOpen ? win.barHeight + win.calHeight + 8 : win.barHeight

                    // ----- clock -----
                    Text {
                        id: label
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: win.revealed ? (win.barHeight - implicitHeight) / 2 : -implicitHeight
                        opacity: win.revealed ? 1 : 0
                        text: Qt.formatDateTime(clock.date, "hh:mm AP")
                        color: "#e6e6e6"
                        font.family: win.fontFamily
                        font.pixelSize: 15

                        Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                    }

                    MouseArea {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: label.implicitWidth + 32
                        height: win.barHeight
                        enabled: win.revealed
                        cursorShape: Qt.PointingHandCursor
                        onClicked: win.calOpen ? win.calOpen = false : win.openCalendar()
                    }

                    // ----- calendar -----
                    Rectangle {
                        id: card
                        width: win.calWidth
                        height: win.calHeight
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: win.calOpen ? win.barHeight + 4 : win.barHeight - 8
                        opacity: win.calOpen ? 1 : 0
                        visible: opacity > 0
                        radius: 14
                        color: "#0e0e0e"
                        border.color: "#2a2a2a"

                        Behavior on y { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                        Behavior on opacity { NumberAnimation { duration: 160 } }

                        Column {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 8

                            // month header
                            Item {
                                width: parent.width
                                height: 28

                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: Qt.formatDate(new Date(win.viewYear, win.viewMonth, 1), "MMMM yyyy")
                                    color: "#e6e6e6"
                                    font.family: win.fontFamily
                                    font.pixelSize: 14
                                    font.bold: true
                                }

                                Row {
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 4
                                    Repeater {
                                        model: [{ g: "‹", d: -1 }, { g: "›", d: 1 }]
                                        Item {
                                            required property var modelData
                                            width: 26
                                            height: 26
                                            Text {
                                                anchors.centerIn: parent
                                                text: parent.modelData.g
                                                color: arrowMa.containsMouse ? "#e6e6e6" : "#6b6b6b"
                                                font.family: win.fontFamily
                                                font.pixelSize: 18
                                                Behavior on color { ColorAnimation { duration: 100 } }
                                            }
                                            MouseArea {
                                                id: arrowMa
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: win.shiftMonth(parent.modelData.d)
                                            }
                                        }
                                    }
                                }
                            }

                            // weekday names
                            Row {
                                Repeater {
                                    model: win.weekdays
                                    Text {
                                        required property string modelData
                                        width: 34
                                        horizontalAlignment: Text.AlignHCenter
                                        text: modelData
                                        color: "#6b6b6b"
                                        font.family: win.fontFamily
                                        font.pixelSize: 12
                                    }
                                }
                            }

                            // day grid (6 rows x 7 cols)
                            Grid {
                                columns: 7
                                Repeater {
                                    model: 42
                                    Item {
                                        required property int index
                                        readonly property int day: index - win.offset + 1
                                        readonly property bool valid: day >= 1 && day <= win.daysInMonth
                                        readonly property bool isToday: valid
                                            && day === clock.date.getDate()
                                            && win.viewMonth === clock.date.getMonth()
                                            && win.viewYear === clock.date.getFullYear()
                                        width: 34
                                        height: 30

                                        Rectangle {
                                            anchors.centerIn: parent
                                            width: 26
                                            height: 26
                                            radius: 13
                                            color: "#e6e6e6"
                                            visible: parent.isToday
                                        }
                                        Text {
                                            anchors.centerIn: parent
                                            visible: parent.valid
                                            text: parent.day
                                            color: parent.isToday ? "#0e0e0e" : "#e6e6e6"
                                            font.family: win.fontFamily
                                            font.pixelSize: 13
                                            font.bold: parent.isToday
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Dwell before showing; 2s linger after the cursor leaves.
                // Closing the bar also closes the calendar.
                Timer { id: showTimer; interval: 120; onTriggered: win.revealed = true }
                Timer {
                    id: hideTimer
                    interval: 2000
                    onTriggered: { win.revealed = false; win.calOpen = false; }
                }

                HoverHandler {
                    onHoveredChanged: {
                        if (hovered) {
                            hideTimer.stop();
                            showTimer.restart();
                        } else {
                            showTimer.stop();
                            hideTimer.restart();
                        }
                    }
                }
            }
        }
    }
}
