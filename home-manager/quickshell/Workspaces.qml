import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

RowLayout {
    id: root
    spacing: 4

    Component.onCompleted: {
        Hyprland.refreshWorkspaces();
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: Hyprland.refreshWorkspaces()
    }

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            id: wsBtn
            required property var modelData
            readonly property int wsId: modelData ? modelData.id : 0
            readonly property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId
            visible: wsId > 0

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
                    if (wsBtn.modelData && typeof wsBtn.modelData.activate === "function") {
                        wsBtn.modelData.activate();
                    } else {
                        Hyprland.dispatch("workspace " + wsBtn.wsId);
                    }
                }
            }
        }
    }
}
