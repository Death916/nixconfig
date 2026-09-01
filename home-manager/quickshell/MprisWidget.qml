import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

Rectangle {
    id: root
    implicitHeight: 24
    implicitWidth: player ? Math.min(contentRow.implicitWidth + 16, 260) : 0
    visible: player !== null
    radius: Theme.radius
    color: mprisMouse.containsMouse ? Theme.hoverBg : Theme.widgetBg

    readonly property var player: {
        if (!Mpris.players || !Mpris.players.values) return null;
        for (let i = 0; i < Mpris.players.values.length; ++i) {
            let p = Mpris.players.values[i];
            if (p && (p.isPlaying || (p.trackTitle && p.trackTitle.length > 0))) {
                return p;
            }
        }
        return Mpris.players.values.length > 0 ? Mpris.players.values[0] : null;
    }

    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: root.player && root.player.isPlaying ? "" : ""
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.accent
        }

        Text {
            id: trackInfo
            text: {
                if (!root.player) return "";
                let title = root.player.trackTitle || "Unknown Track";
                let artist = root.player.trackArtist || "";
                return artist ? `${title} - ${artist}` : title;
            }
            elide: Text.ElideRight
            width: Math.min(implicitWidth, 200)
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.fg
        }
    }

    MouseArea {
        id: mprisMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (!root.player) return;
            if (mouse.button === Qt.LeftButton) {
                root.player.togglePlaying();
            } else if (mouse.button === Qt.RightButton) {
                root.player.next();
            }
        }
    }
}
