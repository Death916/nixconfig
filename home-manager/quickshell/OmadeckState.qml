pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    property bool opened: false

    function toggle() {
        root.opened = !root.opened;
    }

    function open() {
        root.opened = true;
    }

    function close() {
        root.opened = false;
    }

    GlobalShortcut {
        name: "omadeck"
        description: "Toggle Omadeck Overview"
        onPressed: root.toggle()
    }

    IpcHandler {
        target: "omadeck"

        function toggle(): void {
            root.toggle();
        }

        function open(): void {
            root.open();
        }

        function close(): void {
            root.close();
        }
    }
}
