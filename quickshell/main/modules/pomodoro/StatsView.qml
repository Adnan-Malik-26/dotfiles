import QtQuick
import QtQuick.Layouts
import "../../theme"
import "../../services"
import "../../components"

Item {
    id: root
    property bool active: false
    property string chartMode: "week"      // "week" | "hours"
    property real grow: 1                  // bar grow-in animation, shared by both charts

    visible: opacity > 0
    opacity: active ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: Theme.animation } }
    onActiveChanged: if (active) growAnim.restart()
    onChartModeChanged: growAnim.restart()

    NumberAnimation {
        id: growAnim
        target: root
        property: "grow"
        from: 0
        to: 1
        duration: 450
        easing.type: Easing.OutCubic
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // summary cards
        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Repeater {
                model: [
                    { v: Pomodoro.fmtMins(Pomodoro.todayMinutes), l: "today" },
                    { v: Pomodoro.fmtMins(Pomodoro.weekMinutes), l: "7 days" },
                    { v: Pomodoro.streak + "d", l: "streak" }
                ]
                Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 58
                    radius: Theme.layout.rowRadius
                    color: Theme.colors.surface
                    Column {
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.v
                            color: Theme.colors.text
                            font.pixelSize: Theme.font.sizeLarge
                            font.family: Theme.font.family
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.l
                            color: Theme.colors.textMuted
                            font.pixelSize: Theme.font.sizeSmall
                            font.family: Theme.font.family
                        }
                    }
                }
            }
        }

        // chart selector (+ peak hour when looking at time of day)
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Chip { label: "7 days"; active: root.chartMode === "week"; onClicked: root.chartMode = "week" }
            Chip { label: "time of day"; active: root.chartMode === "hours"; onClicked: root.chartMode = "hours" }
            Item { Layout.fillWidth: true }
            Text {
                visible: root.chartMode === "hours"
                text: Pomodoro.peakLabel
                color: Theme.colors.textMuted
                font.pixelSize: Theme.font.sizeSmall + 1
                font.family: Theme.font.family
            }
        }

        // charts (stacked, cross-faded)
        Item {
            Layout.fillWidth: true
            implicitHeight: 140

            // 7-day bars: oldest -> today
            Canvas {
                id: weekChart
                anchors.fill: parent
                opacity: root.chartMode === "week" ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 150 } }

                Connections {
                    target: Pomodoro
                    function onWeekDataChanged() { weekChart.requestPaint() }
                }
                Connections {
                    target: root
                    function onGrowChanged() { weekChart.requestPaint() }
                }
                onPaint: {
                    var c = getContext("2d");
                    c.reset();
                    var data = Pomodoro.weekData, n = data.length;
                    var maxM = 30;
                    for (var i = 0; i < n; i++) maxM = Math.max(maxM, data[i].minutes);
                    var slot = width / n, barW = slot * 0.5;
                    var top = 18, bottom = height - 20, usable = bottom - top;
                    c.font = Theme.font.sizeSmall + 'px "' + Theme.font.family + '"';
                    c.textAlign = "center";
                    for (var j = 0; j < n; j++) {
                        var x = j * slot + (slot - barW) / 2;
                        var h = Math.max(2, (data[j].minutes / maxM) * usable * root.grow);
                        c.fillStyle = data[j].minutes === 0 ? Theme.colors.border
                                    : (data[j].today ? Theme.colors.text : Theme.colors.sliderTrack);
                        c.fillRect(x, bottom - h, barW, h);
                        c.fillStyle = data[j].today ? Theme.colors.text : Theme.colors.textMuted;
                        c.fillText(data[j].label, j * slot + slot / 2, height - 5);
                        if (data[j].minutes > 0 && root.grow > 0.9) {
                            c.fillStyle = Theme.colors.textMuted;
                            c.fillText(Pomodoro.fmtShort(data[j].minutes), j * slot + slot / 2, bottom - h - 5);
                        }
                    }
                }
            }

            // time of day: 24 bars, all-time minutes per hour, peak highlighted
            Canvas {
                id: hourChart
                anchors.fill: parent
                opacity: root.chartMode === "hours" ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 150 } }

                Connections {
                    target: Pomodoro
                    function onHourDataChanged() { hourChart.requestPaint() }
                }
                Connections {
                    target: root
                    function onGrowChanged() { hourChart.requestPaint() }
                }
                onPaint: {
                    var c = getContext("2d");
                    c.reset();
                    var data = Pomodoro.hourData, n = 24, peak = Pomodoro.peakHour;
                    var maxM = 10;
                    for (var i = 0; i < n; i++) maxM = Math.max(maxM, data[i]);
                    var slot = width / n, barW = slot * 0.62;
                    var top = 8, bottom = height - 20, usable = bottom - top;
                    c.font = Theme.font.sizeSmall + 'px "' + Theme.font.family + '"';
                    c.textAlign = "center";
                    for (var j = 0; j < n; j++) {
                        var x = j * slot + (slot - barW) / 2;
                        var h = Math.max(2, (data[j] / maxM) * usable * root.grow);
                        c.fillStyle = data[j] === 0 ? Theme.colors.border
                                    : (j === peak ? Theme.colors.text : Theme.colors.sliderTrack);
                        c.fillRect(x, bottom - h, barW, h);
                        if (j % 6 === 0) {
                            c.fillStyle = Theme.colors.textMuted;
                            c.fillText((j < 10 ? "0" : "") + j, j * slot + slot / 2, height - 5);
                        }
                    }
                }
            }
        }

        Text {
            text: "by tag · all time"
            color: Theme.colors.textMuted
            font.pixelSize: Theme.font.sizeSmall
            font.family: Theme.font.family
        }

        ListView {
            id: tagList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: Pomodoro.tagTotals

            Text {
                anchors.centerIn: parent
                visible: Pomodoro.sessions.length === 0
                text: "no sessions yet"
                color: Theme.colors.sliderTrack
                font.pixelSize: Theme.font.sizeSmall + 1
                font.family: Theme.font.family
            }

            delegate: Item {
                required property var modelData
                width: tagList.width
                height: 34

                Text {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    text: modelData.tag
                    color: Theme.colors.text
                    font.pixelSize: Theme.font.sizeNormal
                    font.family: Theme.font.family
                }
                Text {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    text: Pomodoro.fmtMins(modelData.minutes) + "  ·  " + modelData.count
                    color: Theme.colors.textMuted
                    font.pixelSize: Theme.font.sizeSmall + 1
                    font.family: Theme.font.family
                }
                Rectangle {
                    id: track
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 3
                    radius: 1.5
                    color: Theme.colors.border
                    Rectangle {
                        height: parent.height
                        radius: parent.radius
                        color: Theme.colors.text
                        width: track.width * modelData.minutes / Math.max(1, Pomodoro.tagTotals[0].minutes)
                        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                    }
                }
            }
        }
    }
}
