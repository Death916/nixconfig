{
  config,
  pkgs,
  inputs,
  lib,
  osConfig,
  ...
}:

{
  home.packages = [
    inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.playerctl
    pkgs.pamixer
    pkgs.brightnessctl
    pkgs.papirus-icon-theme
  ];

  xdg.configFile."quickshell".source = ./quickshell;
}
