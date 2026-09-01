import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    implicitHeight: 24
    implicitWidth: contentRow.implicitWidth + 16
    radius: Theme.radius
    color: wttrMouse.containsMouse || weatherPopup.visible ? Theme.hoverBg : Theme.widgetBg

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
            text: root.weatherText.length > 0 ? `${root.weatherText}°` : "..."
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
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                weatherPopup.visible = !weatherPopup.visible;
            } else if (mouse.button === Qt.RightButton) {
                if (!wttrProc.running) {
                    wttrProc.running = true;
                }
            }
        }
    }

    PopupWindow {
        id: weatherPopup
        anchor.item: root
        visible: false
        color: "transparent"
        grabFocus: true

        Rectangle {
            id: popupCard
            anchors.fill: parent
            radius: Theme.radius + 4
            color: Theme.barBg
            border.color: Theme.bgAlt
            border.width: 1

            Text {
                id: forecastContent
                anchors.fill: parent
                anchors.margins: 14
                text: root.weatherTooltip.length > 0 ? root.weatherTooltip : "Fetching forecast..."
                textFormat: Text.RichText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.fg
                lineHeight: 1.2
            }
        }

        implicitWidth: forecastContent.implicitWidth + 28
        implicitHeight: forecastContent.implicitHeight + 28
    }
}
