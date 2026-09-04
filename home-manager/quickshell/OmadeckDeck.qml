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

    // Array of workspace entries:
    // [{ wsId, label, monitor, windows: [{ toplevel, title, x, y, width, height }] }]
    property var entries: []
    property int selectedIndex: 0

    // -------------------------------------------------------------------------
    // Helper: Extract window rectangles from Hyprland IPC data
    // -------------------------------------------------------------------------
    function windowsFor(workspace, monitor) {
        let out = [];
        if (!workspace || !monitor) return out;

        let toplevels = workspace.toplevels ? workspace.toplevels.values : [];
        for (let i = 0; i < toplevels.length; i++) {
            let handle = toplevels[i];
            // ScreencopyView requires the Wayland Toplevel handle (handle.wayland)
            if (!handle || !handle.wayland) continue;

            let raw = handle.lastIpcObject || {};
            let at = Array.isArray(raw.at) && raw.at.length === 2 ? raw.at : [monitor.x, monitor.y];
            let size = Array.isArray(raw.size) && raw.size.length === 2 ? raw.size : [monitor.width, monitor.height];

            let width = Math.max(0, Number(size[0]) || 0);
            let height = Math.max(0, Number(size[1]) || 0);
            if (width <= 0 || height <= 0) continue;

            out.push({
                toplevel: handle.wayland,
                title: handle.title || raw.title || raw.class || "Window",
                // Convert absolute coordinates to monitor-local logical coordinates
                x: (Number(at[0]) || 0) - (monitor.x || 0),
                y: (Number(at[1]) || 0) - (monitor.y || 0),
                width: width,
                height: height
            });
        }
        return out;
    }

    // -------------------------------------------------------------------------
    // Build Workspace Entries
    // -------------------------------------------------------------------------
    function buildEntries() {
        Hyprland.refreshToplevels();

        let focusedMonitor = Hyprland.focusedMonitor;
        let focusedWorkspace = Hyprland.focusedWorkspace;
        let values = Hyprland.workspaces ? Hyprland.workspaces.values : [];
        let built = [];

        for (let i = 0; i < values.length; i++) {
            let workspace = values[i];
            if (!workspace || workspace.id <= 0) continue;

            let monitor = workspace.monitor || focusedMonitor;
            if (focusedMonitor && monitor && monitor.id !== focusedMonitor.id) {
                continue;
            }

            let occupied = workspace.toplevels && workspace.toplevels.values && workspace.toplevels.values.length > 0;
            let isCurrent = focusedWorkspace && workspace.id === focusedWorkspace.id;

            // Show occupied workspaces or the currently focused one
            if (!occupied && !isCurrent) continue;

            built.push({
                wsId: workspace.id,
                label: workspace.name && workspace.name !== String(workspace.id)
                    ? workspace.name
                    : "Workspace " + workspace.id,
                monitor: monitor,
                windows: windowsFor(workspace, monitor)
            });
        }

        built.sort((a, b) => a.wsId - b.wsId);
        root.entries = built;
        syncSelection();
    }

    function syncSelection() {
        let focusedId = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1;
        for (let i = 0; i < root.entries.length; i++) {
            if (root.entries[i].wsId === focusedId) {
                root.selectedIndex = i;
                return;
            }
        }
        root.selectedIndex = 0;
    }

    // Rebuild entries on mount and whenever Omadeck is summoned
    Component.onCompleted: buildEntries()

    Connections {
        target: OmadeckState
        function onOpenedChanged() {
            if (OmadeckState.opened) {
                root.buildEntries();
            }
        }
    }

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            if (OmadeckState.opened) {
                root.syncSelection();
            }
        }
    }

    // -------------------------------------------------------------------------
    // Geometry Constants
    // -------------------------------------------------------------------------
    readonly property int cardWidth: Math.min(Math.max(parent.width * 0.45, 520), 680)
    readonly property int cardHeight: Math.min(Math.max(parent.height * 0.85, 340), 440)
    readonly property int overlapStep: 140
    readonly property int centerX: parent.width / 2

    // -------------------------------------------------------------------------
    // Workspace Cards Repeater
    // -------------------------------------------------------------------------
    Repeater {
        model: root.entries

        Rectangle {
            id: card
            required property var modelData
            required property int index

            readonly property int wsId: modelData.wsId
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
                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
            }

            Behavior on scale {
                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
            }

            Behavior on border.color {
                ColorAnimation { duration: 180 }
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
                            text: card.modelData.label
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

            // Canvas area representing the desktop monitor
            Item {
                id: canvas
                anchors.top: cardHeader.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 10
                clip: true

                // Scaled monitor stage matching monitor aspect ratio
                Item {
                    id: stage
                    readonly property var monitor: card.modelData.monitor || Hyprland.focusedMonitor
                    readonly property real monScale: monitor && monitor.scale > 0 ? monitor.scale : 1
                    // Hyprland reports monitor dimensions in physical pixels; convert to logical pixels
                    readonly property real monWidth: monitor && monitor.width > 0 ? monitor.width / monScale : 1920
                    readonly property real monHeight: monitor && monitor.height > 0 ? monitor.height / monScale : 1080
                    readonly property real coverScale: Math.max(canvas.width / monWidth, canvas.height / monHeight)

                    width: monWidth * coverScale
                    height: monHeight * coverScale
                    anchors.centerIn: parent

                    // Render Windows on this Workspace
                    Repeater {
                        model: card.modelData.windows

                        Item {
                            id: windowSlot
                            required property var modelData
                            required property int index

                            x: modelData.x * stage.coverScale
                            y: modelData.y * stage.coverScale
                            width: Math.max(24, modelData.width * stage.coverScale)
                            height: Math.max(24, modelData.height * stage.coverScale)
                            z: index

                            Rectangle {
                                anchors.fill: parent
                                radius: 4
                                color: Theme.bgSubtle
                                border.color: Theme.bgAlt
                                border.width: 1
                                clip: true

                                // ScreencopyView captured using Wayland Toplevel handle
                                ScreencopyView {
                                    anchors.fill: parent
                                    captureSource: windowSlot.modelData.toplevel
                                    live: false
                                    paintCursor: false
                                }

                                // Title bar / Window identifier
                                Rectangle {
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: 18
                                    color: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, 0.78)

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
                                            text: windowSlot.modelData.title
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
                }
            }

            // Dimming Overlay for non-selected cards
            Rectangle {
                anchors.fill: parent
                radius: card.radius
                color: Theme.bg
                opacity: card.isSelected ? 0.0 : Math.min(0.65, 0.24 + 0.08 * (Math.abs(card.offset) - 1))

                Behavior on opacity {
                    NumberAnimation { duration: 180 }
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
