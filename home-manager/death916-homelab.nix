# ~/nixconfig/home-manager/death916-homelab.nix.new
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
  home.homeDirectory = "/home/death916";

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
