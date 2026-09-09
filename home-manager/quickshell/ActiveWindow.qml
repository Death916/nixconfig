import QtQuick
import Quickshell.Hyprland

Item {
    id: root
    implicitHeight: 24
    implicitWidth: Math.min(titleText.implicitWidth + 16, 280)
    visible: titleText.text.length > 0

    property string activeTitle: {
        if (!Hyprland.focusedWorkspace) return "";
        if (Hyprland.focusedWorkspace.lastWindow) {
            return Hyprland.focusedWorkspace.lastWindow.title || "";
        }
        return "";
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.widgetBg
        radius: Theme.radius

        Text {
            id: titleText
            anchors.centerIn: parent
            anchors.margins: 8
            width: Math.min(implicitWidth, 260)
            text: root.activeTitle
            elide: Text.ElideRight
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.fgSubtle
        }
    }
}
