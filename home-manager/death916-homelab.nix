# ./home-manager/death916-homelab.nix
{ config, pkgs, lib, inputs, ... }:

{
  home.username = "death916";
  home.homeDirectory = "/home/death916";

  # Basic shell configuration (can be more elaborate)
  programs.bash.enable = true;
  programs.git.enable = true;

  # Server-specific tools or dotfiles for death916
  programs.tmux.enable = true; # Example from your repo image

  # Example: Different shell prompt or aliases for server environment
  # programs.bash.shellAliases = {
  #   ll = "ls -alh";
  #   update-system = "sudo nixos-rebuild switch --flake /etc/nixos#homelab";
  # };

  home.packages = with pkgs; [
    # Any user-specific packages for death916 on the server
    fastetch
  ];

  # Keep this consistent with your system's state version
  home.stateVersion = "24.11";
}
