import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    color: "transparent"

    // Background panel with margin & rounded corners
    Rectangle {
        anchors {
            fill: parent
            topMargin: 4
            leftMargin: 8
            rightMargin: 8
            bottomMargin: 2
        }
        radius: Theme.radius
        color: Theme.barBg
        border.color: Theme.bgAlt
        border.width: 1

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 8
                rightMargin: 8
            }
            spacing: 8

            // Left: Workspaces & Active Window Title
            RowLayout {
                Layout.alignment: Qt.AlignLeft
                spacing: 8

                Workspaces {}
                ActiveWindow {}
            }

            Item { Layout.fillWidth: true }

            // Center: Clock & Media
            RowLayout {
                Layout.alignment: Qt.AlignCenter
                spacing: 8

                Clock {}
                MprisWidget {}
            }

            Item { Layout.fillWidth: true }

            // Right: System Tray, Audio, Battery
            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 6

                SysTray {}
                VolumeWidget {}
                BatteryWidget {}
            }
        }
    }
}
