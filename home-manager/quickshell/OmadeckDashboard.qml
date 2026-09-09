import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

RowLayout {
    id: root
    spacing: 16
    Layout.alignment: Qt.AlignHCenter

    // -------------------------------------------------------------------------
    // CAVA Spectrum State
    // -------------------------------------------------------------------------
    property var spectrum: []
    property bool spectrumUnavailable: false
    readonly property string cavaConfigPath: Quickshell.env("HOME") + "/.config/quickshell/cava.conf"

    // -------------------------------------------------------------------------
    // Active MPRIS Player
    // -------------------------------------------------------------------------
    readonly property var activePlayer: {
        if (!Mpris.players || !Mpris.players.values) return null;
        for (let i = 0; i < Mpris.players.values.length; ++i) {
            let p = Mpris.players.values[i];
            if (p && (p.isPlaying || (p.trackTitle && p.trackTitle.length > 0))) {
                return p;
            }
        }
        return Mpris.players.values.length > 0 ? Mpris.players.values[0] : null;
    }
    readonly property bool hasMedia: activePlayer !== null

    // Track position timer
    property real mediaPosition: 0
    Timer {
        interval: 500
        repeat: true
        running: OmadeckState.opened && root.hasMedia
        triggeredOnStart: true
        onTriggered: {
            root.mediaPosition = root.activePlayer ? root.activePlayer.position : 0;
        }
    }

    // CAVA Process
    Process {
        id: cavaProc
        command: ["cava", "-p", root.cavaConfigPath]
        running: OmadeckState.opened && root.hasMedia && !root.spectrumUnavailable

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(line) {
                let text = String(line).trim();
                if (!text || text.length > 1024) return;
                let parts = text.split(";");
                let vals = [];
                for (let i = 0; i < parts.length; i++) {
                    if (parts[i] === "") continue;
                    let n = Number(parts[i]);
                    if (isFinite(n)) {
                        vals.push(Math.min(100, Math.max(0, n)));
                    }
                }
                if (vals.length > 0) {
                    root.spectrum = vals;
                }
            }
        }

        onExited: function(code) {
            root.spectrum = [];
            root.spectrumUnavailable = true;
        }
    }

    Connections {
        target: OmadeckState
        function onOpenedChanged() {
            if (OmadeckState.opened) {
                root.spectrumUnavailable = false;
            } else {
                root.spectrum = [];
            }
        }
    }

    // =========================================================================
    // CARD 1: Clock & Calendar Card
    // =========================================================================
    Rectangle {
        id: clockCard
        implicitWidth: 280
        implicitHeight: 180
        radius: Theme.radius + 6
        color: Theme.barBg
        border.color: Theme.bgAlt
        border.width: 1

        property var now: new Date()
        Timer {
            interval: 1000
            running: OmadeckState.opened
            repeat: true
            onTriggered: clockCard.now = new Date()
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 4

            // Top: Icon + Weekday
            RowLayout {
                spacing: 8
                Text {
                    text: "󰥔"
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                    color: Theme.accent
                }
                Text {
                    text: Qt.formatDateTime(clockCard.now, "dddd").toUpperCase()
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeSmall
                    font.letterSpacing: 2
                    font.bold: true
                    color: Theme.fgSubtle
                }
            }

            Item { Layout.fillHeight: true }

            // Center: Big Time
            RowLayout {
                spacing: 4
                Text {
                    text: Qt.formatDateTime(clockCard.now, "HH:mm")
                    font.family: Theme.fontFamily
                    font.pixelSize: 42
                    font.bold: true
                    color: Theme.fg
                }
                Text {
                    text: ":" + Qt.formatDateTime(clockCard.now, "ss")
                    font.family: Theme.fontFamily
                    font.pixelSize: 22
                    color: Theme.accent
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 8
                }
            }

            Item { Layout.fillHeight: true }

            // Bottom: Full Date
            Text {
                text: Qt.formatDateTime(clockCard.now, "MMMM d, yyyy")
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeNormal
                color: Theme.fgSubtle
            }
        }
    }

    // =========================================================================
    // CARD 2: Media Player Card with Live CAVA Spectrum
    // =========================================================================
    Rectangle {
        id: mediaCard
        implicitWidth: 460
        implicitHeight: 180
        radius: Theme.radius + 6
        color: Theme.barBg
        border.color: Theme.bgAlt
        border.width: 1
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            // Top row: Album art + Track info + Controls
            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                // Album Art
                Rectangle {
                    implicitWidth: 70
                    implicitHeight: 70
                    radius: Theme.radius
                    color: Theme.bgSubtle
                    clip: true

                    Image {
                        id: trackArt
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        source: root.activePlayer && root.activePlayer.trackArtUrl ? root.activePlayer.trackArtUrl : ""
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: trackArt.status !== Image.Ready
                        text: "󰎆"
                        font.family: Theme.fontFamily
                        font.pixelSize: 28
                        color: Theme.accent
                    }
                }

                // Track details & Controls
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        Layout.fillWidth: true
                        text: root.activePlayer && root.activePlayer.trackTitle ? root.activePlayer.trackTitle : "No Media Playing"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeNormal
                        font.bold: true
                        color: Theme.fg
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.activePlayer && root.activePlayer.trackArtist ? root.activePlayer.trackArtist : (root.activePlayer ? root.activePlayer.identity || "Media" : "Idle")
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.fgSubtle
                        elide: Text.ElideRight
                    }

                    // Playback buttons
                    RowLayout {
                        spacing: 12
                        Layout.topMargin: 4

                        // Prev
                        Text {
                            text: "󰒮"
                            font.family: Theme.fontFamily
                            font.pixelSize: 18
                            color: prevMouse.containsMouse ? Theme.accent : Theme.fg
                            MouseArea {
                                id: prevMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (root.activePlayer) root.activePlayer.previous()
                            }
                        }

                        // Play/Pause
                        Rectangle {
                            implicitWidth: 30
                            implicitHeight: 30
                            radius: 15
                            color: playMouse.containsMouse ? Theme.accent : Theme.bgAlt

                            Text {
                                anchors.centerIn: parent
                                text: root.activePlayer && root.activePlayer.isPlaying ? "󰏤" : "󰐊"
                                font.family: Theme.fontFamily
                                font.pixelSize: 14
                                color: playMouse.containsMouse ? Theme.bgSubtle : Theme.fg
                            }

                            MouseArea {
                                id: playMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (root.activePlayer) root.activePlayer.togglePlaying()
                            }
                        }

                        // Next
                        Text {
                            text: "󰒭"
                            font.family: Theme.fontFamily
                            font.pixelSize: 18
                            color: nextMouse.containsMouse ? Theme.accent : Theme.fg
                            MouseArea {
                                id: nextMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (root.activePlayer) root.activePlayer.next()
                            }
                        }
                    }
                }
            }

            // Progress Bar
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 3
                radius: 1.5
                color: Theme.bgAlt

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    radius: 1.5
                    color: Theme.accent
                    width: {
                        if (!root.activePlayer || root.activePlayer.length <= 0) return 0;
                        let ratio = root.mediaPosition / root.activePlayer.length;
                        return Math.min(parent.width, Math.max(0, parent.width * ratio));
                    }
                }
            }

            // Bottom: Live CAVA Visualizer (32 bars)
            RowLayout {
                Layout.fillWidth: true
                implicitHeight: 38
                spacing: 3

                Repeater {
                    model: 32

                    Rectangle {
                        required property int index
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignBottom
                        radius: 2

                        // Reactive height from CAVA spectrum (0 to 100)
                        implicitHeight: {
                            if (!root.hasMedia || !root.spectrum || root.spectrum.length === 0) {
                                return 3; // Minimal resting bar
                            }
                            let val = root.spectrum[index] || 0;
                            return Math.max(3, (val / 100.0) * 36);
                        }

                        color: {
                            if (root.activePlayer && root.activePlayer.isPlaying) {
                                return Theme.accent;
                            }
                            return Theme.surface;
                        }

                        opacity: root.activePlayer && root.activePlayer.isPlaying ? 0.9 : 0.4

                        Behavior on implicitHeight {
                            NumberAnimation { duration: 50; easing.type: Easing.OutQuad }
                        }
                    }
                }
            }
        }
    }

    // =========================================================================
    // CARD 3: Weather Card
    // =========================================================================
    Rectangle {
        id: weatherCard
        implicitWidth: 320
        implicitHeight: 180
        radius: Theme.radius + 6
        color: Theme.barBg
        border.color: Theme.bgAlt
        border.width: 1

        property string weatherText: ""
        property string weatherTooltip: ""

        readonly property var info: {
            let raw = weatherCard.weatherTooltip;
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
            running: OmadeckState.opened

            stdout: SplitParser {
                onRead: function(data) {
                    try {
                        let parsed = JSON.parse(data.trim());
                        if (parsed.text) weatherCard.weatherText = parsed.text;
                        if (parsed.tooltip) weatherCard.weatherTooltip = parsed.tooltip;
                    } catch (e) {}
                }
            }
        }

        Timer {
            interval: 900000 // 15 mins
            running: OmadeckState.opened
            repeat: true
            onTriggered: {
                if (!wttrProc.running) wttrProc.running = true;
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 6

            // Header: City + Condition Icon
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: weatherCard.info.city
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSizeNormal
                    font.bold: true
                    color: Theme.fg
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: weatherCard.weatherText.length > 0 ? `${weatherCard.weatherText}°F` : "..."
                    font.family: Theme.fontFamily
                    font.pixelSize: 20
                    font.bold: true
                    color: Theme.accent
                }
            }

            Text {
                text: weatherCard.info.current
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.fgSubtle
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            // Stats row
            RowLayout {
                spacing: 12
                Layout.topMargin: 2

                Text {
                    text: weatherCard.info.feelsLike ? `Feels: ${weatherCard.info.feelsLike}` : ""
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: Theme.fgSubtle
                }
                Text {
                    text: weatherCard.info.wind ? `󰄝 ${weatherCard.info.wind}` : ""
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: Theme.fgSubtle
                }
                Text {
                    text: weatherCard.info.humidity ? `󰖆 ${weatherCard.info.humidity}` : ""
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    color: Theme.fgSubtle
                }
            }

            Item { Layout.fillHeight: true }

            // 3-Day Forecast row
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: weatherCard.info.days.slice(0, 3)

                    Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: 34
                        radius: Theme.radius
                        color: Theme.widgetBg

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            Text {
                                text: modelData.icon
                                font.pixelSize: 12
                            }
                            Text {
                                text: `${modelData.high || "-"}/${modelData.low || "-"}`
                                font.family: Theme.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                                color: Theme.fg
                            }
                        }
                    }
                }
            }
        }
    }
}
