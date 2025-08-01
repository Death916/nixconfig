{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [ ../modules/home-manager/common.nix ];

  home.username = "death916";
  home.stateVersion = "25.05";

  programs.bash.enable = true;

  home.packages = with pkgs; [
    fastfetch
    wget
    zellij
    systemctl-tui
    gemini-cli
    
  ];

  programs.bash.shellAliases = {
    nh-push = "/home/death916/nixconfig/scripts/nh-push";
  };
}
