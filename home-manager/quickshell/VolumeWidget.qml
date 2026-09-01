import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Hyprland

Rectangle {
    id: root
    implicitHeight: 24
    implicitWidth: contentRow.implicitWidth + 16
    radius: Theme.radius
    color: volMouse.containsMouse ? Theme.hoverBg : Theme.widgetBg

    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool isMuted: sink && sink.audio ? sink.audio.muted : false
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0.0
    readonly property int volumePercent: Math.round(root.volume * 100)

    readonly property string icon: {
        if (root.isMuted) return "󰝟";
        if (root.volumePercent >= 60) return "󰕾";
        if (root.volumePercent > 0) return "󰖀";
        return "󰕿";
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: root.icon
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeIcon
            color: root.isMuted ? Theme.red : Theme.accent
        }

        Text {
            text: root.isMuted ? "Muted" : `${root.volumePercent}%`
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: root.isMuted ? Theme.fgSubtle : Theme.fg
        }
    }

    MouseArea {
        id: volMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                if (root.sink && root.sink.audio) {
                    root.sink.audio.muted = !root.sink.audio.muted;
                }
            } else if (mouse.button === Qt.RightButton) {
                Hyprland.dispatch("exec pavucontrol");
            }
        }

        onWheel: (wheel) => {
            if (!root.sink || !root.sink.audio) return;
            if (wheel.angleDelta.y > 0) {
                root.sink.audio.volume = Math.min(1.5, root.sink.audio.volume + 0.05);
            } else if (wheel.angleDelta.y < 0) {
                root.sink.audio.volume = Math.max(0.0, root.sink.audio.volume - 0.05);
            }
        }
    }
}
