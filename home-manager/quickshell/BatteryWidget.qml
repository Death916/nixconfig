import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

Rectangle {
    id: root
    implicitHeight: 24
    implicitWidth: contentRow.implicitWidth + 16
    radius: Theme.radius
    color: batMouse.containsMouse ? Theme.hoverBg : Theme.widgetBg
    visible: UPower.displayDevice && UPower.displayDevice.ready && UPower.displayDevice.isPresent

    readonly property var dev: UPower.displayDevice
    readonly property int percent: dev && dev.ready ? Math.round(dev.percentage <= 1.0 ? dev.percentage * 100 : dev.percentage) : 100
    readonly property bool isCharging: dev && dev.ready && (dev.state === UPowerDeviceState.Charging || dev.state === UPowerDeviceState.FullyCharged)

    readonly property string icon: {
        if (root.isCharging) return "󰂄";
        if (root.percent >= 90) return "󰁹";
        if (root.percent >= 80) return "󰂂";
        if (root.percent >= 60) return "󰂀";
        if (root.percent >= 40) return "󰁾";
        if (root.percent >= 20) return "󰁼";
        return "󰁺";
    }

    readonly property color iconColor: {
        if (root.isCharging) return Theme.green;
        if (root.percent <= 20) return Theme.red;
        if (root.percent <= 35) return Theme.yellow;
        return Theme.accent;
    }

    function formatTime(seconds) {
        if (!seconds || seconds <= 0) return "";
        let hours = Math.floor(seconds / 3600);
        let minutes = Math.floor((seconds % 3600) / 60);
        if (hours > 0) {
            return `${hours}h ${minutes}m`;
        }
        return `${minutes}m`;
    }

    readonly property string statusText: {
        if (!dev || !dev.ready) return "";
        if (dev.state === UPowerDeviceState.FullyCharged) {
            return "Full";
        }
        if (dev.state === UPowerDeviceState.Charging || dev.state === UPowerDeviceState.PendingCharge) {
            let t = formatTime(dev.timeToFull);
            return t ? `Charging (${t} to full)` : "Charging";
        }
        if (dev.state === UPowerDeviceState.Discharging || dev.state === UPowerDeviceState.PendingDischarge) {
            let t = formatTime(dev.timeToEmpty);
            return t ? `${t} left` : "Discharging";
        }
        return "";
    }

    Behavior on implicitWidth {
        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.icon
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeIcon
            color: root.iconColor
        }

        Text {
            text: `${root.percent}%`
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.fg
        }

        Text {
            visible: batMouse.containsMouse && root.statusText.length > 0
            text: `•  ${root.statusText}`
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.fgSubtle
        }
    }

    MouseArea {
        id: batMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
