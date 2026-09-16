import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

RowLayout {
    id: root
    spacing: 4

    Component.onCompleted: {
        Hyprland.refreshWorkspaces();
        console.log("[Quickshell Workspaces] Initialized, workspaces count:", Hyprland.workspaces && Hyprland.workspaces.values ? Hyprland.workspaces.values.length : 0);
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            Hyprland.refreshWorkspaces();
        }
    }

    Repeater {
        model: 10

        Rectangle {
            id: wsBtn
            readonly property int wsId: index + 1
            readonly property var ws: Hyprland.workspaces && Hyprland.workspaces.values ? Hyprland.workspaces.values.find(w => w.id === wsId) : null
            readonly property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
            readonly property bool isOccupied: ws !== null && ws !== undefined

            visible: isOccupied || isFocused

            implicitWidth: isFocused ? 28 : 22
            implicitHeight: 22
            radius: Theme.radius

            color: isFocused ? Theme.accent : Theme.widgetBg
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
                color: wsBtn.isFocused ? Theme.bgSubtle : Theme.fg
            }

            MouseArea {
                id: wsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (wsBtn.ws && typeof wsBtn.ws.activate === "function") {
                        wsBtn.ws.activate();
                    } else {
                        Hyprland.dispatch("workspace " + wsBtn.wsId);
                    }
                }
            }
        }
    }
}
