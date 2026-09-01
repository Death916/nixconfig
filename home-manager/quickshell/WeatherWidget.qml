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

    readonly property var weatherData: {
        if (!root.weatherTooltip || root.weatherTooltip.length === 0) {
            return { header: "Fetching forecast...", days: [] };
        }
        let sections = root.weatherTooltip.trim().split("\n\n");
        let header = sections[0] || "";
        let days = [];
        for (let i = 1; i < sections.length; ++i) {
            if (sections[i].trim().length > 0) {
                days.push(sections[i].trim());
            }
        }
        return { header: header, days: days };
    }

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
            right: 12
        }
        implicitWidth: popupCard.implicitWidth
        implicitHeight: popupCard.implicitHeight
        color: "transparent"
        visible: root.popupOpen

        Rectangle {
            id: popupCard
            implicitWidth: mainLayout.implicitWidth + 28
            implicitHeight: mainLayout.implicitHeight + 28
            radius: Theme.radius + 6
            color: Theme.barBg
            border.color: Theme.bgAlt
            border.width: 1

            ColumnLayout {
                id: mainLayout
                anchors.centerIn: parent
                spacing: 10

                // Header Card: Current conditions & location
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: headerText.implicitHeight + 16
                    radius: Theme.radius
                    color: Theme.widgetBg

                    Text {
                        id: headerText
                        anchors.centerIn: parent
                        text: root.weatherData.header
                        textFormat: Text.StyledText
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.fg
                        lineHeight: 1.25
                    }
                }

                // 3-Day Forecast Columns side by side
                RowLayout {
                    spacing: 10

                    Repeater {
                        model: root.weatherData.days

                        Rectangle {
                            required property string modelData
                            required property int index

                            implicitWidth: dayText.implicitWidth + 20
                            implicitHeight: dayText.implicitHeight + 20
                            radius: Theme.radius
                            color: Theme.widgetBg

                            Text {
                                id: dayText
                                anchors.centerIn: parent
                                text: modelData
                                textFormat: Text.StyledText
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                color: Theme.fg
                                lineHeight: 1.25
                            }
                        }
                    }
                }
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
