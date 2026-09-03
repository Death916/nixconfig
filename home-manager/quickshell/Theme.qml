pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property color bg: "#1b1e28"
    readonly property color bgSubtle: "#232735"
    readonly property color bgAlt: "#303545"
    readonly property color surface: "#505770"
    readonly property color fg: "#a6accd"
    readonly property color fgSubtle: "#767c9d"
    readonly property color accent: "#7697d6"
    readonly property color accentAlt: "#fcc5e9"
    readonly property color green: "#5de4c7"
    readonly property color yellow: "#fffac2"
    readonly property color red: "#d0679d"
    readonly property color barBg: "#d91b1e28"
    readonly property color widgetBg: "#40303545"
    readonly property color hoverBg: "#60505770"
    readonly property color activeBg: "#807697d6"

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeNormal: 13
    readonly property int fontSizeLarge: 15
    readonly property int fontSizeIcon: 15

    readonly property int radius: 8
    readonly property int barHeight: 34
}
