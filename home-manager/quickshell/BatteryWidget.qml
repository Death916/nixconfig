import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

Rectangle {
    id: root
    implicitHeight: 24
    implicitWidth: contentRow.implicitWidth + 16
    radius: Theme.radius
    color: Theme.widgetBg
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

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 4

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
    }
}
