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
        implicitWidth: popupCard.implicitWidth
        implicitHeight: popupCard.implicitHeight
        color: "transparent"
        visible: root.popupOpen

        Rectangle {
            id: popupCard
            implicitWidth: forecastText.implicitWidth + 32
            implicitHeight: forecastText.implicitHeight + 24
            radius: Theme.radius + 4
            color: Theme.barBg
            border.color: Theme.bgAlt
            border.width: 1

            Text {
                id: forecastText
                anchors.centerIn: parent
                text: root.weatherTooltip.length > 0 ? root.weatherTooltip : "Fetching forecast..."
                textFormat: Text.RichText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.fg
                lineHeight: 1.2
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.popupOpen = false;
                }
            }
        }
    }
}
