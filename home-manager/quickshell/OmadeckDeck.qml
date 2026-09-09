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
//
// Matches upstream iryzhkov/omarchy-omadeck (Carousel.qml):
// - Direct 1:1 window capture via hyprland-toplevel-export-v1 (handle.wayland)
// - Static frame capture per summon (live: false) to eliminate GPU rendering strain
// - Stable Repeater hierarchy indexed by integer length (no modelData shadowing)
// - Fanned head-on stack with depth ordering and active accent border
// =============================================================================
Item {
    id: root
    anchors.fill: parent

    property bool opened: false
    property var screen: null

    signal dismissed()
    signal workspaceSelected(int wsId)

    // Array of workspace entries:
    // [{ wsId, label, monitor, windows: [{ toplevel, x, y, width, height }] }]
    property var entries: []
    property int selectedIndex: 0

    // Bounding helpers
    function finiteNum(value, lo, hi, fallback) {
        let n = Number(value);
        if (!isFinite(n)) return fallback;
        return Math.min(hi, Math.max(lo, n));
    }

    function boundText(value, max) {
        let s = String(value === undefined || value === null ? "" : value);
        return s.length > max ? s.slice(0, max) : s;
    }

    // Geometry layout knobs matching upstream Carousel.qml
    readonly property int sliceWidth: Math.min(Math.max(root.width * 0.45, 520), 660)
    readonly property int sliceHeight: Math.min(Math.max(root.height * 0.55, 340), 429)
    readonly property int overlapStep: 140
    readonly property int captureRadius: 6

    // -------------------------------------------------------------------------
    // Helper: Resolve monitor for a workspace
    // -------------------------------------------------------------------------
    function monitorForWorkspace(workspace) {
        return workspace && workspace.monitor ? workspace.monitor : Hyprland.focusedMonitor;
    }

    // -------------------------------------------------------------------------
    // Helper: Extract window rectangles from Hyprland IPC and toplevel handles
    // -------------------------------------------------------------------------
    function windowsFor(workspace, monitor) {
        let out = [];
        if (!workspace || !monitor) return out;

        let toplevels = [];
        if (workspace.toplevels && workspace.toplevels.values && workspace.toplevels.values.length > 0) {
            toplevels = workspace.toplevels.values;
        } else if (Hyprland.toplevels && Hyprland.toplevels.values) {
            toplevels = Hyprland.toplevels.values.filter(t => t && t.workspace && t.workspace.id === workspace.id);
        }

        let monX = (monitor && typeof monitor.x === "number") ? monitor.x : 0;
        let monY = (monitor && typeof monitor.y === "number") ? monitor.y : 0;
        let monW = (monitor && typeof monitor.width === "number") ? monitor.width : 1920;
        let monH = (monitor && typeof monitor.height === "number") ? monitor.height : 1080;

        for (let i = 0; i < toplevels.length; i++) {
            let handle = toplevels[i];
            if (!handle) continue;

            let raw = handle.lastIpcObject || {};
            let at = Array.isArray(raw.at) && raw.at.length === 2 ? raw.at : [monX, monY];
            let size = Array.isArray(raw.size) && raw.size.length === 2 ? raw.size : [monW, monH];

            let width = finiteNum(size[0], 0, 32768, 0);
            let height = finiteNum(size[1], 0, 32768, 0);
            if (width <= 0 || height <= 0) continue;

            out.push({
                toplevel: handle.wayland || null,
                title: handle.title || raw.title || raw.class || "Window",
                x: finiteNum(at[0], -32768, 32768, 0) - monX,
                y: finiteNum(at[1], -32768, 32768, 0) - monY,
                width: width,
                height: height
            });

            if (out.length >= 64) break;
        }

        return out;
    }

    // -------------------------------------------------------------------------
    // Build Workspace Entries
    // -------------------------------------------------------------------------
    function buildEntries() {
        Hyprland.refreshToplevels();
        Hyprland.refreshWorkspaces();

        let focusedMonitor = Hyprland.focusedMonitor;
        let focusedWorkspace = Hyprland.focusedWorkspace;
        let values = Hyprland.workspaces ? Hyprland.workspaces.values : [];
        let built = [];

        for (let i = 0; i < values.length; i++) {
            let workspace = values[i];
            if (!workspace || workspace.id <= 0) continue;

            let monitor = monitorForWorkspace(workspace);
            if (focusedMonitor && monitor && monitor.id !== focusedMonitor.id) {
                continue;
            }

            let occupied = (workspace.toplevels && workspace.toplevels.values && workspace.toplevels.values.length > 0)
                || (Hyprland.toplevels && Hyprland.toplevels.values && Hyprland.toplevels.values.some(t => t && t.workspace && t.workspace.id === workspace.id));
            let current = focusedWorkspace && workspace.id === focusedWorkspace.id;

            // Show occupied workspaces or the currently active one
            if (!occupied && !current) continue;

            built.push({
                wsId: workspace.id,
                label: workspace.name && workspace.name !== String(workspace.id)
                    ? boundText(workspace.name, 128)
                    : "Workspace " + workspace.id,
                monitor: monitor,
                windows: windowsFor(workspace, monitor)
            });

            if (built.length >= 64) break;
        }

        built.sort((a, b) => a.wsId - b.wsId);
        root.entries = built;
        syncSelection(false);
    }

    function indexOfWorkspace(wsId) {
        for (let i = 0; i < root.entries.length; i++) {
            if (root.entries[i].wsId === wsId) return i;
        }
        return -1;
    }

    function syncSelection(allowRebuild) {
        let focused = Hyprland.focusedWorkspace;
        if (!focused) return;

        let index = indexOfWorkspace(focused.id);
        if (index < 0 && allowRebuild !== false) {
            buildEntries();
            index = indexOfWorkspace(focused.id);
        }

        if (index >= 0) {
            root.selectedIndex = index;
        }
    }

    function jumpTo(index) {
        let entry = root.entries[index];
        if (!entry) return;

        let wsId = Number(entry.wsId);
        if (!Number.isInteger(wsId) || wsId <= 0) return;

        root.workspaceSelected(wsId);
        Hyprland.dispatch(`hl.dsp.focus({ workspace = "${wsId}" })`);
    }

    // Single retry timer on summon to ensure Wayland toplevel addresses settle
    Timer {
        id: retryTimer
        interval: 100
        repeat: false
        onTriggered: {
            if (root.opened || OmadeckState.opened) {
                root.buildEntries();
            }
        }
    }

    // Initial mount and summon triggers
    Component.onCompleted: {
        buildEntries();
    }

    onOpenedChanged: {
        if (opened) {
            root.buildEntries();
            retryTimer.restart();
        }
    }

    Connections {
        target: OmadeckState
        function onOpenedChanged() {
            if (OmadeckState.opened) {
                root.buildEntries();
                retryTimer.restart();
            }
        }
    }

    Connections {
        target: Hyprland
        function onFocusedWorkspaceChanged() {
            if (root.opened || OmadeckState.opened) {
                root.syncSelection(true);
            }
        }
    }

    // -------------------------------------------------------------------------
    // Workspace Cards Fanned Carousel
    // -------------------------------------------------------------------------
    Item {
        id: strip
        anchors.fill: parent

        // Consume clicks in empty deck area
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Repeater {
            model: root.entries.length

            Item {
                id: slice
                required property int index

                readonly property var entry: root.entries[index]
                readonly property int relativeIndex: index - root.selectedIndex
                readonly property int depth: Math.abs(relativeIndex)
                readonly property bool selected: relativeIndex === 0
                readonly property bool nearby: depth <= root.captureRadius

                // Once activated, keep capture alive to avoid teardown flicker
                property bool captureActivated: nearby
                onNearbyChanged: {
                    if (nearby) captureActivated = true;
                }

                visible: nearby
                width: root.sliceWidth
                height: root.sliceHeight
                anchors.verticalCenter: parent.verticalCenter
                x: (strip.width - root.sliceWidth) / 2 + (relativeIndex * root.overlapStep)
                z: root.captureRadius - depth

                Behavior on x {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }

                // Card surface container
                Rectangle {
                    anchors.fill: parent
                    color: Theme.bgSubtle
                    radius: Theme.radius + 4
                    clip: true

                    // Scaled monitor stage matching monitor aspect ratio
                    Item {
                        id: stage

                        readonly property var monitor: slice.entry ? slice.entry.monitor : null
                        readonly property real monitorScale: monitor && monitor.scale > 0 ? monitor.scale : 1
                        readonly property real monitorWidth: monitor && monitor.width > 0 ? monitor.width / monitorScale : 1920
                        readonly property real monitorHeight: monitor && monitor.height > 0 ? monitor.height / monitorScale : 1080
                        readonly property real coverScale: Math.max(parent.width / monitorWidth, parent.height / monitorHeight)

                        width: monitorWidth * coverScale
                        height: monitorHeight * coverScale
                        anchors.centerIn: parent

                        // Empty workspace indicator
                        Text {
                            anchors.centerIn: parent
                            visible: !slice.entry || !slice.entry.windows || slice.entry.windows.length === 0
                            text: "Empty Workspace"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.fgSubtle
                            opacity: 0.5
                        }

                        // Window previews captured via hyprland-toplevel-export
                        Repeater {
                            model: slice.captureActivated && slice.entry ? slice.entry.windows.length : 0

                            Item {
                                id: windowSlot
                                required property int index
                                readonly property var spec: slice.entry.windows[index]

                                x: spec.x * stage.coverScale
                                y: spec.y * stage.coverScale
                                width: Math.max(16, spec.width * stage.coverScale)
                                height: Math.max(16, spec.height * stage.coverScale)
                                z: index

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 4
                                    color: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, 0.75)
                                    border.color: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.18)
                                    border.width: 1
                                    clip: true

                                    ScreencopyView {
                                        id: scView
                                        anchors.fill: parent
                                        captureSource: windowSlot.spec.toplevel
                                        live: root.opened || OmadeckState.opened
                                        paintCursor: false
                                        visible: captureSource !== null && hasContent
                                    }

                                    // Fallback / loading label when frame is not ready
                                    Text {
                                        anchors.centerIn: parent
                                        visible: !scView.visible
                                        text: windowSlot.spec.title || "Window"
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Math.max(9, Math.min(13, windowSlot.height * 0.15))
                                        font.bold: true
                                        color: Theme.fg
                                        elide: Text.ElideRight
                                        width: Math.max(0, parent.width - 12)
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }
                        }
                    }

                    // Depth dimming overlay: unselected cards dim further into the stack
                    Rectangle {
                        anchors.fill: parent
                        color: Theme.bg
                        opacity: slice.selected ? 0.0 : Math.min(0.65, 0.25 + 0.10 * (slice.depth - 1))

                        Behavior on opacity {
                            NumberAnimation { duration: 180 }
                        }
                    }

                    // Workspace Label Pill
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.margins: 10
                        implicitWidth: labelText.implicitWidth + 16
                        implicitHeight: 24
                        radius: Theme.radius
                        color: slice.selected ? Theme.accent : Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, 0.8)

                        Text {
                            id: labelText
                            anchors.centerIn: parent
                            text: slice.entry ? slice.entry.label : ""
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                            color: slice.selected ? Theme.bgSubtle : Theme.fg
                        }
                    }
                }

                // Card Outline Border
                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radius + 4
                    color: "transparent"
                    border.color: slice.selected ? Theme.accent : Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.25)
                    border.width: slice.selected ? 2 : 1

                    Behavior on border.color {
                        ColorAnimation { duration: 180 }
                    }
                }

                // Click interaction
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (slice.selected) {
                            root.dismissed();
                        } else {
                            root.jumpTo(slice.index);
                        }
                    }
                }
            }
        }
    }
}
