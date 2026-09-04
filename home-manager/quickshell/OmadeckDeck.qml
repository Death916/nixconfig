import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

// =============================================================================
// DETACHABLE WORKSPACE OVERVIEW DECK
// =============================================================================
// This component is strictly isolated. When Hyprland implements native overview
// support, this component can be completely unplugged or removed without
// affecting the Omadeck HUD or any dashboard widgets.
// =============================================================================
Item {
    id: root

    property bool opened: false
    property var screen: null

    signal dismissed()
    signal workspaceSelected(int wsId)

    // -------------------------------------------------------------------------
    // Workspaces Model
    // -------------------------------------------------------------------------
    readonly property var activeWorkspaces: {
        if (!Hyprland.workspaces || !Hyprland.workspaces.values) return [];
        let list = [];
        let focusedId = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1;

        for (let i = 0; i < Hyprland.workspaces.values.length; ++i) {
            let ws = Hyprland.workspaces.values[i];
            if (!ws || ws.id <= 0) continue;

            // Check if workspace has windows or is focused
            let hasWindows = ws.toplevels && ws.toplevels.values && ws.toplevels.values.length > 0;
            if (hasWindows || ws.id === focusedId) {
                list.push(ws);
            }
        }

        // Ensure focused workspace is in the list
        if (focusedId > 0 && !list.some(w => w.id === focusedId)) {
            list.push(Hyprland.focusedWorkspace);
        }

        list.sort((a, b) => a.id - b.id);
        return list;
    }

    readonly property int selectedIndex: {
        let focusedId = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1;
        for (let i = 0; i < activeWorkspaces.length; ++i) {
            if (activeWorkspaces[i].id === focusedId) return i;
        }
        return 0;
    }

    // Geometry constants
    readonly property int cardWidth: Math.min(Math.max(parent.width * 0.45, 520), 680)
    readonly property int cardHeight: Math.min(Math.max(parent.height * 0.85, 340), 440)
    readonly property int overlapStep: 140
    readonly property int centerX: parent.width / 2

    // Monitor resolution for window scaling
    readonly property real monWidth: root.screen ? root.screen.width : 1920
    readonly property real monHeight: root.screen ? root.screen.height : 1080

    // -------------------------------------------------------------------------
    // Workspace Cards Repeater
    // -------------------------------------------------------------------------
    Repeater {
        model: root.activeWorkspaces

        Rectangle {
            id: card
            required property var modelData
            required property int index

            readonly property int wsId: modelData.id
            readonly property int offset: index - root.selectedIndex
            readonly property bool isSelected: offset === 0

            width: root.cardWidth
            height: root.cardHeight
            radius: Theme.radius + 6
            color: Theme.barBg

            // Centering & Fanning position
            x: root.centerX - (root.cardWidth / 2) + (offset * root.overlapStep)
            anchors.verticalCenter: parent.verticalCenter

            // Stacking order: selected on top, descending to left & right
            z: isSelected ? 100 : (offset < 0 ? 50 + index : 50 - offset)

            // Scale and border
            scale: isSelected ? 1.0 : Math.max(0.85, 1.0 - Math.abs(offset) * 0.05)
            border.color: isSelected ? Theme.accent : Theme.bgAlt
            border.width: isSelected ? 2 : 1
            clip: true

            Behavior on x {
                NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
            }

            Behavior on scale {
                NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
            }

            Behavior on border.color {
                ColorAnimation { duration: 200 }
            }

            // Top Header Bar
            Rectangle {
                id: cardHeader
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 36
                color: card.isSelected ? Theme.bgSubtle : Theme.widgetBg

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14

                    // Workspace indicator pill
                    Rectangle {
                        implicitWidth: wsText.implicitWidth + 14
                        implicitHeight: 22
                        radius: Theme.radius
                        color: card.isSelected ? Theme.accent : Theme.bgAlt

                        Text {
                            id: wsText
                            anchors.centerIn: parent
                            text: `Workspace ${card.wsId}`
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                            color: card.isSelected ? Theme.bgSubtle : Theme.fg
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // "ACTIVE" badge if selected
                    Rectangle {
                        visible: card.isSelected
                        implicitWidth: activeBadge.implicitWidth + 10
                        implicitHeight: 18
                        radius: Theme.radius
                        color: Theme.activeBg

                        Text {
                            id: activeBadge
                            anchors.centerIn: parent
                            text: "ACTIVE"
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            color: Theme.accent
                        }
                    }
                }
            }

            // Canvas area representing the desktop
            Item {
                id: canvas
                anchors.top: cardHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10

                // Aspect-ratio scaled container
                readonly property real scaleFactor: Math.min(
                    canvas.width / root.monWidth,
                    canvas.height / root.monHeight
                )

                // Render Windows on this Workspace
                Repeater {
                    model: {
                        if (!Hyprland.toplevels || !Hyprland.toplevels.values) return [];
                        return Hyprland.toplevels.values.filter(t => t && t.workspace && t.workspace.id === card.wsId);
                    }

                    Rectangle {
                        id: winRect
                        required property var modelData

                        // Scaled positioning
                        x: Math.max(0, (modelData.x % root.monWidth) * canvas.scaleFactor)
                        y: Math.max(0, (modelData.y % root.monHeight) * canvas.scaleFactor)
                        width: Math.max(30, modelData.width * canvas.scaleFactor)
                        height: Math.max(30, modelData.height * canvas.scaleFactor)
                        radius: 4
                        color: Theme.bgSubtle
                        border.color: modelData.activated ? Theme.accent : Theme.bgAlt
                        border.width: 1
                        clip: true

                        // Live window screencopy stream
                        ScreencopyView {
                            anchors.fill: parent
                            captureSource: winRect.modelData
                            live: root.opened
                            paintCursor: false
                            visible: hasContent
                        }

                        // Window Title Bar / Fallback Label
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 18
                            color: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, 0.8)

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 4
                                anchors.rightMargin: 4
                                spacing: 4

                                Text {
                                    text: "󰖲"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    color: Theme.accent
                                }

                                Text {
                                    text: winRect.modelData.title || winRect.modelData.class || "Window"
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 10
                                    color: Theme.fg
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }

            // Dimming Overlay for non-selected cards
            Rectangle {
                anchors.fill: parent
                radius: card.radius
                color: Theme.bg
                opacity: card.isSelected ? 0.0 : Math.min(0.65, 0.25 * Math.abs(card.offset))

                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }
            }

            // Click Handler
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true

                onClicked: {
                    if (card.isSelected) {
                        // Clicking the active workspace dismisses the overview
                        root.dismissed();
                    } else {
                        // Switch to clicked workspace
                        Hyprland.dispatch(`hl.dsp.focus({ workspace = "${card.wsId}" })`);
                        root.workspaceSelected(card.wsId);
                    }
                }
            }
        }
    }
}
