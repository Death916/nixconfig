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

    implicitHeight: 24
    implicitWidth: contentRow.implicitWidth + 16
    radius: Theme.radius
    color: scaleMouse.containsMouse ? Theme.hoverBg : Theme.widgetBg

    Process {
        id: scaleProc
    }

    function applyScale(target) {
        let mon = Hyprland.monitorFor(root.screen);
        let name = mon ? mon.name : (root.screen ? root.screen.name : "eDP-1");
        let res = (name === "eDP-1") ? "2880x1800@120" : "preferred";
        let pos = (name === "eDP-1") ? "0x0" : "auto";
        let val = target.toFixed(2);
        scaleProc.command = ["hyprctl", "keyword", "monitor", `${name},${res},${pos},${val}`];
        scaleProc.running = true;
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: "󰍹"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: root.currentScale > 1.3 ? Theme.accent : Theme.fg
        }

        Text {
            text: `${root.currentScale.toFixed(2)}x`
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.bold: root.currentScale > 1.3
            color: root.currentScale > 1.3 ? Theme.accent : Theme.fg
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
                // One-click toggle between default 1.25 and glasses 1.50
                let next = (Math.abs(root.currentScale - 1.25) < 0.05) ? 1.50 : 1.25;
                root.applyScale(next);
            } else if (mouse.button === Qt.RightButton) {
                // Cycle through common scale presets
                let presets = [1.25, 1.40, 1.50, 1.60, 1.75];
                let idx = presets.findIndex(s => Math.abs(s - root.currentScale) < 0.05);
                let nextIdx = (idx + 1) % presets.length;
                root.applyScale(presets[nextIdx]);
            }
        }

        onWheel: (wheel) => {
            let presets = [1.0, 1.15, 1.25, 1.40, 1.50, 1.60, 1.75, 2.0];
            let current = root.currentScale;
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
