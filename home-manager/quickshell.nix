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
  ];

  xdg.configFile."quickshell".source = ./quickshell;
}
