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

    readonly property var info: {
        let raw = root.weatherTooltip;
        if (!raw || raw.length === 0) {
            return {
                city: "Sacramento",
                current: "Loading...",
                feelsLike: "",
                wind: "",
                humidity: "",
                days: []
            };
        }
        let sections = raw.trim().split("\n\n");
        let headerLines = (sections[0] || "").split("\n");
        let currentCond = headerLines[0] ? headerLines[0].replace(/<[^>]*>/g, "").trim() : "";
        let feelsLike = "";
        let wind = "";
        let humidity = "";
        let location = "Sacramento";
        for (let i = 0; i < headerLines.length; ++i) {
            let line = headerLines[i].trim();
            if (line.startsWith("Feels Like:")) feelsLike = line.replace("Feels Like:", "").trim();
            else if (line.startsWith("Wind:")) wind = line.replace("Wind:", "").trim();
            else if (line.startsWith("Humidity:")) humidity = line.replace("Humidity:", "").trim();
            else if (line.startsWith("Location:")) location = line.replace("Location:", "").trim();
        }

        let days = [];
        for (let s = 1; s < sections.length; ++s) {
            let lines = sections[s].trim().split("\n");
            if (lines.length === 0) continue;
            let rawTitle = lines[0].replace(/<[^>]*>/g, "").trim();
            let title = rawTitle.split(",")[0].trim();
            let stats = lines[1] || "";
            let highMatch = stats.match(/⬆️\s*(\d+°)/);
            let lowMatch = stats.match(/⬇️\s*(\d+°)/);
            let high = highMatch ? highMatch[1] : "";
            let low = lowMatch ? lowMatch[1] : "";

            let noon = lines.find(l => l.trim().startsWith("12") || l.trim().startsWith("15")) || lines[2] || "";
            let noonTokens = noon.trim().split(/\s+/);
            let icon = noonTokens[1] || "🌤️";
            let descPart = noon.replace(/^\d+\s+/, "").replace(/^[^\s]+\s+/, "");
            let condition = descPart.split(",")[0].replace(/^\d+°\s*/, "").trim();

            days.push({
                title: title,
                icon: icon,
                condition: condition,
                high: high,
                low: low
            });
        }

        return {
            city: location.split(",")[0].trim(),
            current: currentCond,
            feelsLike: feelsLike,
            wind: wind,
            humidity: humidity,
            days: days
        };
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
        implicitWidth: 360
        implicitHeight: popupCard.implicitHeight
        color: "transparent"
        visible: root.popupOpen

        Rectangle {
            id: popupCard
            implicitWidth: 360
            implicitHeight: mainLayout.implicitHeight + 28
            radius: Theme.radius + 6
            color: Theme.barBg
            border.color: Theme.bgAlt
            border.width: 1

            ColumnLayout {
                id: mainLayout
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 14
                }
                spacing: 10

                // Header: Location & Current Weather
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: root.info.city
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.bold: true
                            color: Theme.accent
                        }
                        Text {
                            text: root.info.current
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.fg
                        }
                        Text {
                            visible: root.info.feelsLike.length > 0
                            text: `Feels like: ${root.info.feelsLike}`
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSizeSmall
                            color: Theme.fgSubtle
                        }
                    }

                    Item { Layout.fillWidth: true }

                    ColumnLayout {
                        spacing: 4
                        Layout.alignment: Qt.AlignRight

                        Rectangle {
                            visible: root.info.wind.length > 0
                            implicitHeight: 20
                            implicitWidth: windText.implicitWidth + 12
                            radius: Theme.radius
                            color: Theme.widgetBg
                            Text {
                                id: windText
                                anchors.centerIn: parent
                                text: `󰈐 ${root.info.wind}`
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                color: Theme.fgSubtle
                            }
                        }

                        Rectangle {
                            visible: root.info.humidity.length > 0
                            implicitHeight: 20
                            implicitWidth: humText.implicitWidth + 12
                            radius: Theme.radius
                            color: Theme.widgetBg
                            Text {
                                id: humText
                                anchors.centerIn: parent
                                text: `󰖎 ${root.info.humidity}`
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                color: Theme.fgSubtle
                            }
                        }
                    }
                }

                // Subtle divider
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: Theme.bgAlt
                }

                // Daily Forecast List
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: root.info.days

                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 32
                            radius: Theme.radius
                            color: Theme.widgetBg

                            RowLayout {
                                anchors {
                                    fill: parent
                                    leftMargin: 10
                                    rightMargin: 10
                                }
                                spacing: 8

                                // Day Name
                                Text {
                                    Layout.preferredWidth: 80
                                    text: modelData.title
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: true
                                    color: Theme.fg
                                }

                                // Weather Icon
                                Text {
                                    text: modelData.icon
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 14
                                }

                                // Condition summary
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.condition
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.fgSubtle
                                    elide: Text.ElideRight
                                }

                                // High / Low temps
                                Text {
                                    text: `${modelData.high}  ${modelData.low}`
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.bold: true
                                    color: Theme.accent
                                }
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
