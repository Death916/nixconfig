import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland

RowLayout {
    id: root
    spacing: 4

    property var activeList: []

    function updateList() {
        Hyprland.refreshWorkspaces();
        if (!Hyprland.workspaces || !Hyprland.workspaces.values) {
            root.activeList = [];
            return;
        }

        let list = [];
        for (let i = 0; i < Hyprland.workspaces.values.length; ++i) {
            let ws = Hyprland.workspaces.values[i];
            if (ws && ws.id > 0) {
                list.push(ws);
            }
        }
        if (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id > 0) {
            if (!list.some(ws => ws.id === Hyprland.focusedWorkspace.id)) {
                list.push(Hyprland.focusedWorkspace);
            }
        }
        list.sort((a, b) => a.id - b.id);
        root.activeList = list;
    }

    Component.onCompleted: updateList()

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() { root.updateList(); }
        function onRawEvent(event) { root.updateList(); }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.updateList()
    }

    Repeater {
        model: root.activeList

        Rectangle {
            id: wsBtn
            required property var modelData
            readonly property int wsId: modelData.id
            readonly property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsId

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
