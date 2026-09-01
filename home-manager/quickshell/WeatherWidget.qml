import QtQuick
import QtQuick.Layouts
import Quickshell.Io

Rectangle {
    id: root
    implicitHeight: 24
    implicitWidth: contentRow.implicitWidth + 16
    radius: Theme.radius
    color: wttrMouse.containsMouse ? Theme.hoverBg : Theme.widgetBg

    property string weatherText: ""
    property string weatherTooltip: ""

    Process {
        id: wttrProc
        command: ["wttrbar", "--location", "Sacramento", "--fahrenheit"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    let parsed = JSON.parse(data.trim());
                    if (parsed.text) {
                        root.weatherText = parsed.text;
                    }
                    if (parsed.tooltip) {
                        root.weatherTooltip = parsed.tooltip;
                    }
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 1800000 // Refresh every 30 minutes
        running: true
        repeat: true
        onTriggered: {
            if (!wttrProc.running) {
                wttrProc.running = true;
            }
        }
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: root.weatherText.length > 0 ? root.weatherText : "..."
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.fg
        }
    }

    MouseArea {
        id: wttrMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (!wttrProc.running) {
                wttrProc.running = true;
            }
        }
    }
}
