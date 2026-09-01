import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

RowLayout {
    id: root
    spacing: 4

    // Fixed list of standard workspaces 1..10
    Repeater {
        model: 10

        Rectangle {
            id: wsBtn
            required property int index
            readonly property int wsId: index + 1
            readonly property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
            readonly property bool isOccupied: {
                if (!Hyprland.workspaces) return false;
                for (let i = 0; i < Hyprland.workspaces.values.length; ++i) {
                    if (Hyprland.workspaces.values[i].id === wsId) return true;
                }
                return false;
            }

            implicitWidth: isFocused ? 28 : 22
            implicitHeight: 22
            radius: Theme.radius

            color: isFocused ? Theme.accent : (isOccupied ? Theme.widgetBg : "transparent")
            border.color: isFocused ? Theme.accent : (wsMouse.containsMouse ? Theme.fgSubtle : "transparent")
            border.width: 1

            Behavior on implicitWidth {
                NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
            }

            Behavior on color {
                ColorAnimation { duration: 150 }
            }

            Text {
                anchors.centerIn: parent
                text: wsBtn.wsId.toString()
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.bold: wsBtn.isFocused
                color: wsBtn.isFocused ? Theme.bgSubtle : (wsBtn.isOccupied ? Theme.fg : Theme.fgSubtle)
            }

            MouseArea {
                id: wsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Hyprland.dispatch(`hl.dsp.focus({ workspace = "${wsBtn.wsId}" })`);
                }
            }
        }
    }
}
