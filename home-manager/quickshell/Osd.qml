import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    anchors {
        bottom: true
    }
    margins {
        bottom: 80
    }

    implicitWidth: 220
    implicitHeight: 48
    color: "transparent"
    visible: osdContainer.opacity > 0.01

    property real osdOpacity: 0.0

    PwObjectTracker {
        objects: Pipewire.defaultAudioSink ? [Pipewire.defaultAudioSink] : []
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink && sink.audio ? sink.audio.volume : 0.0
    readonly property bool isMuted: sink && sink.audio ? sink.audio.muted : false

    onVolumeChanged: {
        root.showOsd();
    }

    onIsMutedChanged: {
        root.showOsd();
    }

    function showOsd() {
        root.osdOpacity = 1.0;
        hideTimer.restart();
    }

    Timer {
        id: hideTimer
        interval: 1800
        onTriggered: {
            root.osdOpacity = 0.0;
        }
    }

    Rectangle {
        id: osdContainer
        anchors.fill: parent
        opacity: root.osdOpacity
        radius: Theme.radius + 4
        color: Theme.barBg
        border.color: Theme.bgAlt
        border.width: 1

        Behavior on opacity {
            NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
        }

        RowLayout {
            anchors.centerIn: parent
            spacing: 12
            width: parent.width - 24

            Text {
                text: root.isMuted ? "󰝟" : (root.volume > 0.5 ? "󰕾" : (root.volume > 0 ? "󰖀" : "󰕿"))
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeLarge + 4
                color: root.isMuted ? Theme.red : Theme.accent
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 8
                radius: 4
                color: Theme.bgAlt

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * Math.min(1.0, root.volume)
                    radius: 4
                    color: root.isMuted ? Theme.fgSubtle : Theme.accent

                    Behavior on width {
                        NumberAnimation { duration: 100 }
                    }
                }
            }

            Text {
                text: root.isMuted ? "Muted" : `${Math.round(root.volume * 100)}%`
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.fg
            }
        }
    }
}
