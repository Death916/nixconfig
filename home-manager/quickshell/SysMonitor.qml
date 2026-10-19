import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// System monitor card for the Omadeck overview: live CPU history graph plus
// RAM / GPU load and CPU / GPU temperatures. Metrics come from sysmon.sh.
Rectangle {
    id: root
    implicitWidth: 340
    implicitHeight: 180
    radius: Theme.radius + 6
    color: Theme.barBg
    border.color: Theme.bgAlt
    border.width: 1

    readonly property int historyLength: 44

    property int cpuPct: 0
    property int memPct: 0
    property int gpuPct: -1
    property int cpuTemp: -1
    property int gpuTemp: -1
    property string load1: "-.--"
    property real memUsed: 0
    property real memTotal: 0
    property var cpuHistory: []
    readonly property bool hasData: root.cpuHistory.length > 0

    // Teal under light load, yellow mid, pink hot.
    function loadColor(pct) {
        if (pct < 0) return Theme.surface;
        if (pct < 50) return Theme.green;
        if (pct < 80) return Theme.yellow;
        return Theme.red;
    }

    Process {
        id: sysmonProc
        // The script lives next to this file in ~/.config/quickshell.
        command: ["bash", Quickshell.env("HOME") + "/.config/quickshell/sysmon.sh"]
        // Sampling only runs while the overview is open, like the cava process.
        running: OmadeckState.opened

        stdout: SplitParser {
            onRead: function(line) {
                let parts = String(line).trim().split(/\s+/);
                if (parts.length < 8) return;

                let vals = [];
                for (let i = 0; i < 8; ++i) {
                    let n = Number(parts[i]);
                    if (!isFinite(n)) return;
                    vals.push(n);
                }

                root.cpuPct = vals[0];
                root.memPct = vals[1];
                root.gpuPct = vals[2];
                root.cpuTemp = vals[3];
                root.gpuTemp = vals[4];
                root.load1 = parts[5];
                root.memUsed = vals[6];
                root.memTotal = vals[7];

                let history = root.cpuHistory.slice();
                history.push(root.cpuPct);
                while (history.length > root.historyLength) history.shift();
                root.cpuHistory = history;
            }
        }
    }

    // Reopening the overview starts a fresh graph for the new sampling run.
    Connections {
        target: OmadeckState
        function onOpenedChanged() {
            if (OmadeckState.opened) {
                root.cpuHistory = [];
                root.cpuPct = 0;
            }
        }
    }

    // Horizontal meter used for RAM / GPU / temperature readouts.
    component Meter: ColumnLayout {
        id: meter
        property string label: ""
        property string value: ""
        property real percent: 0
        property color barColor: Theme.accent
        spacing: 3

        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: meter.label
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.letterSpacing: 1
                color: Theme.fgSubtle
            }
            Item { Layout.fillWidth: true }
            Text {
                text: meter.value
                font.family: Theme.fontFamily
                font.pixelSize: 10
                font.bold: true
                color: Theme.fg
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 3
            radius: 1.5
            color: Theme.bgAlt

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                radius: 1.5
                color: meter.barColor
                width: parent.width * Math.min(1, Math.max(0, meter.percent / 100))

                Behavior on width {
                    NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 8

        // ---------------------------------------------------------------
        // Header: title + load average
        // ---------------------------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: ""
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                color: Theme.accent
            }
            Text {
                text: "SYSTEM"
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.letterSpacing: 2
                font.bold: true
                color: Theme.fgSubtle
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "LOAD " + root.load1
                font.family: Theme.fontFamily
                font.pixelSize: 10
                color: Theme.fgSubtle
            }
        }

        // ---------------------------------------------------------------
        // CPU percentage + rolling history graph
        // ---------------------------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            implicitHeight: 52
            spacing: 12

            ColumnLayout {
                spacing: -2

                Text {
                    text: root.cpuPct + "%"
                    font.family: Theme.fontFamily
                    font.pixelSize: 32
                    font.bold: true
                    color: root.loadColor(root.cpuPct)
                }
                Text {
                    text: "CPU"
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.letterSpacing: 1
                    color: Theme.fgSubtle
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 2

                Repeater {
                    model: root.historyLength

                    Rectangle {
                        id: bar
                        required property int index
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignBottom
                        radius: 1

                        readonly property int sample: bar.index < root.cpuHistory.length
                            ? root.cpuHistory[bar.index]
                            : -1

                        implicitHeight: bar.sample < 0
                            ? 2
                            : Math.max(2, (Math.min(100, bar.sample) / 100) * 46)

                        color: bar.sample < 0 ? Theme.surface : root.loadColor(bar.sample)
                        opacity: bar.sample < 0 ? 0.35 : 0.9

                        Behavior on implicitHeight {
                            NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
                        }
                    }
                }
            }
        }

        // ---------------------------------------------------------------
        // RAM / GPU load + temperatures
        // ---------------------------------------------------------------
        RowLayout {
            Layout.fillWidth: true
            spacing: 14

            Meter {
                Layout.fillWidth: true
                label: "RAM"
                value: root.memPct + "%"
                percent: root.memPct
                barColor: root.loadColor(root.memPct)
            }

            Meter {
                Layout.fillWidth: true
                label: "GPU"
                value: root.gpuPct >= 0 ? root.gpuPct + "%" : "n/a"
                percent: root.gpuPct < 0 ? 0 : root.gpuPct
                barColor: root.loadColor(root.gpuPct)
            }

            Meter {
                Layout.fillWidth: true
                label: "TEMP"
                value: (root.cpuTemp >= 0 ? root.cpuTemp + "\u00b0" : "-") + " / "
                    + (root.gpuTemp >= 0 ? root.gpuTemp + "\u00b0" : "-")
                percent: root.cpuTemp < 0 ? 0 : root.cpuTemp
                barColor: root.cpuTemp < 0 ? Theme.surface : root.loadColor(root.cpuTemp)
            }
        }

        Item { Layout.fillHeight: true }

        // Footer: memory in use
        Text {
            text: root.hasData
                ? "MEM " + root.memUsed.toFixed(1) + " / " + root.memTotal.toFixed(0) + " GiB"
                : "SAMPLING..."
            font.family: Theme.fontFamily
            font.pixelSize: 10
            color: Theme.fgSubtle
        }
    }
}
