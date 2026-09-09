import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    implicitHeight: 24
    implicitWidth: clockText.implicitWidth + 16
    radius: Theme.radius
    color: clockMouse.containsMouse ? Theme.hoverBg : Theme.widgetBg

    property var currentTime: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.currentTime = new Date();
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: "󰥔"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeNormal
            color: Theme.accent
        }

        Text {
            id: clockText
            text: Qt.formatDateTime(root.currentTime, "yyyy-MM-dd HH:mm:ss")
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSizeSmall
            font.bold: true
            color: Theme.fg
        }
    }

    MouseArea {
        id: clockMouse
        anchors.fill: parent
        hoverEnabled: true
    }
}
