import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root
    property var screen: null
    property bool popupOpen: false

    implicitHeight: 24
    implicitWidth: contentRow.implicitWidth + 16
    radius: Theme.radius
    color: wttrMouse.containsMouse || root.popupOpen ? Theme.hoverBg : Theme.widgetBg

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
                root.popupOpen = !root.popupOpen;
            } else if (mouse.button === Qt.RightButton) {
                if (!wttrProc.running) {
                    wttrProc.running = true;
                }
            }
        }
    }

    PanelWindow {
        id: weatherPopup
        screen: root.screen
        anchors {
            top: true
            right: true
        }
        margins {
            top: Theme.barHeight + 6
            right: 8
        }
        implicitWidth: popupCard.width
        implicitHeight: popupCard.height
        color: "transparent"
        visible: root.popupOpen

        Rectangle {
            id: popupCard
            width: Math.min(Math.max(forecastText.implicitWidth + 32, 420), 560)
            height: Math.min(forecastText.implicitHeight + 32, 480)
            radius: Theme.radius + 4
            color: Theme.barBg
            border.color: Theme.bgAlt
            border.width: 1

            Flickable {
                id: flick
                anchors.fill: parent
                anchors.margins: 16
                contentWidth: forecastText.implicitWidth
                contentHeight: forecastText.implicitHeight
                clip: true

                Text {
                    id: forecastText
                    text: root.weatherTooltip.length > 0 ? root.weatherTooltip : "Fetching forecast..."
                    textFormat: Text.StyledText
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                    color: Theme.fg
                    lineHeight: 1.2
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton
                onClicked: {
                    root.popupOpen = false;
                }
            }
        }
    }
}
