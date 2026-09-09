{
  config,
  pkgs,
  inputs,
  lib,
  osConfig,
  ...
}:

let
  c = config.lib.stylix.colors;
in
{
  home.packages = [
    inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.playerctl
    pkgs.pamixer
    pkgs.brightnessctl
    pkgs.papirus-icon-theme
  ];

  xdg.configFile."quickshell" = {
    source = builtins.filterSource (path: type: baseNameOf path != "Theme.qml") ./quickshell;
    recursive = true;
  };

  xdg.configFile."quickshell/Theme.qml".text = ''
    pragma Singleton
    import QtQuick
    import Quickshell

    Singleton {
        readonly property color bg: "#${c.base00}"
        readonly property color bgSubtle: "#${c.base01}"
        readonly property color bgAlt: "#${c.base02}"
        readonly property color surface: "#${c.base03}"
        readonly property color fg: "#${c.base05}"
        readonly property color fgSubtle: "#${c.base04}"
        readonly property color accent: "#${c.base0D}"
        readonly property color accentAlt: "#${c.base0E}"
        readonly property color green: "#${c.base0B}"
        readonly property color yellow: "#${c.base09}"
        readonly property color red: "#${c.base08}"
        readonly property color barBg: "#d9${c.base00}"
        readonly property color widgetBg: "#40${c.base02}"
        readonly property color hoverBg: "#60${c.base03}"
        readonly property color activeBg: "#80${c.base0D}"

        readonly property string fontFamily: "${config.stylix.fonts.monospace.name}"
        readonly property int fontSizeSmall: 11
        readonly property int fontSizeNormal: 13
        readonly property int fontSizeLarge: 15
        readonly property int fontSizeIcon: 15

        readonly property int radius: 8
        readonly property int barHeight: 34
    }
  '';
}
