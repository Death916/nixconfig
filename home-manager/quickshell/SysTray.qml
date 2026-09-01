import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

RowLayout {
    id: root
    spacing: 6

    Repeater {
        model: SystemTray.items ? SystemTray.items.values : []

        Rectangle {
            id: trayItemRect
            required property var modelData
            implicitWidth: 22
            implicitHeight: 22
            radius: Theme.radius
            color: trayMouse.containsMouse ? Theme.hoverBg : "transparent"

            Image {
                anchors.centerIn: parent
                width: 16
                height: 16
                source: trayItemRect.modelData.icon || ""
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            QsMenuAnchor {
                id: menuAnchor
                menu: trayItemRect.modelData.menu
                anchor.item: trayItemRect
            }

            MouseArea {
                id: trayMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        trayItemRect.modelData.activate();
                    } else if (mouse.button === Qt.RightButton && trayItemRect.modelData.hasMenu) {
                        menuAnchor.open();
                    }
                }
            }
        }
    }
}
