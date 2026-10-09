import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    color: "transparent"

    // Burn-in: the pill is nudged up to 5px horizontally / 2px vertically. Those
    // bounds come from its own margins below (8px sides, 4px top, 2px bottom),
    // so it never clips and never opens a gap at the screen edge. The window is
    // never resized or re-anchored, so the compositor never relayouts.
    readonly property var shiftOffsets: [
        [0, 0], [4, 1], [-4, -1], [3, -1], [-3, 1],
        [5, 0], [-5, 0], [2, 2], [-2, -2], [1, -2], [-1, 2]
    ]
    property int shiftX: 0
    property int shiftY: 0

    Behavior on shiftX { NumberAnimation { duration: 700; easing.type: Easing.InOutSine } }
    Behavior on shiftY { NumberAnimation { duration: 700; easing.type: Easing.InOutSine } }

    Timer {
        id: shiftTimer
        running: true
        repeat: true
        interval: 60000
        onTriggered: {
            let pick = Math.floor(Math.random() * root.shiftOffsets.length);
            root.shiftX = root.shiftOffsets[pick][0];
            root.shiftY = root.shiftOffsets[pick][1];
            // Random dwell so the sequence never settles into a fixed cycle.
            interval = 45000 + Math.floor(Math.random() * 75000);
        }
    }

    // Burn-in: dim the bar once the session is idle. Inhibitor-aware, so
    // fullscreen video and other idle inhibitors keep it at full brightness.
    IdleMonitor {
        id: idleMonitor
        timeout: 120
        respectInhibitors: true
    }

    readonly property real contentOpacity: idleMonitor.isIdle ? Theme.idleDimOpacity : 1.0

    Behavior on contentOpacity {
        NumberAnimation { duration: 1200; easing.type: Easing.InOutSine }
    }

    // Background panel with margin & rounded corners
    Rectangle {
        anchors {
            fill: parent
            topMargin: 4
            leftMargin: 8
            rightMargin: 8
            bottomMargin: 2
        }
        radius: Theme.radius
        color: Theme.barBg
        border.color: Theme.bgAlt
        border.width: 1

        opacity: root.contentOpacity
        transform: Translate {
            x: root.shiftX
            y: root.shiftY
        }

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 8
                rightMargin: 8
            }
            spacing: 8

            // Left: Workspaces & Active Window Title
            RowLayout {
                Layout.alignment: Qt.AlignLeft
                spacing: 8

                Workspaces {}
                ActiveWindow {}
            }

            Item { Layout.fillWidth: true }

            // Center: Clock & Media
            RowLayout {
                Layout.alignment: Qt.AlignCenter
                spacing: 8

                Clock {}
                MprisWidget {}
            }

            Item { Layout.fillWidth: true }

            // Right: Weather, System Tray, Audio, Battery
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 6

                ScaleWidget { screen: root.modelData }
                WeatherWidget { screen: root.modelData }
                SysTray {}
                VolumeWidget {}
                BatteryWidget {}
            }
        }
    }
}
