import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    WlrLayershell.namespace: "omadeck"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    visible: OmadeckState.opened

    // =========================================================================
    // MODULAR OVERVIEW CONFIGURATION
    // Set enableWorkspaceDeck to false or delete the Loader below to detach
    // the workspace overview deck when Hyprland has native overview support.
    // =========================================================================
    property bool enableWorkspaceDeck: true

    // Darkened translucent backdrop (scrim)
    Rectangle {
        id: scrim
        anchors.fill: parent
        color: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, 0.82)
        opacity: OmadeckState.opened ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }

        // Clicking the backdrop closes the overlay
        MouseArea {
            anchors.fill: parent
            onClicked: OmadeckState.close()
        }
    }

    // Main Container
    Item {
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: {
            OmadeckState.close();
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 36
            anchors.bottomMargin: 24
            anchors.leftMargin: 36
            anchors.rightMargin: 36
            spacing: 20

            // -----------------------------------------------------------------
            // Top HUD: Clock, Weather, Media Player + CAVA Spectrum
            // -----------------------------------------------------------------
            OmadeckDashboard {
                id: dashboard
                Layout.alignment: Qt.AlignHCenter
            }

            // -----------------------------------------------------------------
            // Bottom Deck: Detachable Workspace Overview
            // -----------------------------------------------------------------
            Loader {
                id: deckLoader
                active: root.enableWorkspaceDeck
                visible: active
                Layout.fillWidth: true
                Layout.fillHeight: true

                sourceComponent: Component {
                    OmadeckDeck {
                        opened: OmadeckState.opened
                        screen: root.screen
                        onDismissed: OmadeckState.close()
                        onWorkspaceSelected: (wsId) => {
                            OmadeckState.close()
                        }
                    }
                }
            }
        }
    }
}
