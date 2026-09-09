import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Rectangle {
    id: root
    property var screen: null

    readonly property var currentMonitor: Hyprland.monitorFor(root.screen)
    readonly property real currentScale: currentMonitor && currentMonitor.scale > 0 ? currentMonitor.scale : 1.25
    property real activeScale: currentScale

    onCurrentScaleChanged: {
        root.activeScale = root.currentScale;
    }

    implicitHeight: 24
    implicitWidth: contentRow.implicitWidth + 16
    radius: Theme.radius
    color: scaleMouse.containsMouse ? Theme.hoverBg : Theme.widgetBg

    Process {
        id: scaleProc
        onExited: {
            running = false;
        }
    }

    Timer {
        id: refreshTimer
        interval: 300
        repeat: false
        onTriggered: {
            Hyprland.refreshMonitors();
        }
    }

    function applyScale(target) {
        let mon = Hyprland.monitorFor(root.screen);
        let name = mon ? mon.name : (root.screen ? root.screen.name : "eDP-1");
        let res = (name === "eDP-1") ? "2880x1800@120" : "preferred";
        let pos = (name === "eDP-1") ? "0x0" : "auto";
        let val = Number(target.toFixed(2));

        root.activeScale = val;

        let luaCall = `hl.monitor({ output = "${name}", mode = "${res}", position = "${pos}", scale = ${val} })`;

        // Dispatch via hyprctl eval through Process
        scaleProc.command = ["hyprctl", "eval", luaCall];
        scaleProc.running = true;

        // Also dispatch via Hyprland IPC exec_cmd as reliable fallback
        let escapedLua = luaCall.replace(/"/g, '\\"');
        Hyprland.dispatch(`hl.dsp.exec_cmd('hyprctl eval "${escapedLua}"')`);

        refreshTimer.restart();
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: "󰍹"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: root.activeScale > 1.3 ? Theme.accent : Theme.fg
        }

        Text {
            text: `${root.activeScale.toFixed(2)}x`
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.bold: root.activeScale > 1.3
            color: root.activeScale > 1.3 ? Theme.accent : Theme.fg
        }
    }

    MouseArea {
        id: scaleMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                // One-click toggle between standard 1.25 and glasses mode 1.50
                let next = (Math.abs(root.activeScale - 1.25) < 0.05) ? 1.50 : 1.25;
                root.applyScale(next);
            } else if (mouse.button === Qt.RightButton) {
                // Cycle through common presets
                let presets = [1.25, 1.40, 1.50, 1.60, 1.75];
                let idx = presets.findIndex(s => Math.abs(s - root.activeScale) < 0.05);
                let nextIdx = (idx + 1) % presets.length;
                root.applyScale(presets[nextIdx]);
            }
        }

        onWheel: (wheel) => {
            let presets = [1.0, 1.15, 1.25, 1.40, 1.50, 1.60, 1.75, 2.0];
            let current = root.activeScale;
            if (wheel.angleDelta.y > 0) {
                let next = presets.find(s => s > current + 0.04) || presets[presets.length - 1];
                root.applyScale(next);
            } else if (wheel.angleDelta.y < 0) {
                let reversed = presets.slice().reverse();
                let next = reversed.find(s => s < current - 0.04) || presets[0];
                root.applyScale(next);
            }
        }
    }
}
