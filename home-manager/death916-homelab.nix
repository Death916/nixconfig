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
  home.stateVersion = "24.11";
  programs.bash.enable = true;

  home.packages = with pkgs; [
    fastfetch
    wget
    zellij
    systemctl-tui
    gemini-cli
    fzf
    eza
  ];

  programs.bash.shellAliases = {
    nh-push = "/home/death916/nixconfig/scripts/nh-push";
    l = "eza -alh --icons";
  };

  programs.fish = {
    enable = true;
    functions = {
      l = {
        body = "eza -alh --icons $argv";
        description = "List files with eza in long format with icons";
      };
      nh-push = {
        body = ''
          /home/death916/Documents/nix-config/scripts/nh-push $argv
        '';
        description = "Wrapper for nh that runs git pull and git push on success";
      };
    };
  };
}
