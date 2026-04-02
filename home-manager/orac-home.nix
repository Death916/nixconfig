{
  config,
  pkgs,
  lib,
  inputs,
  unstablePkgs,
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
    unstablePkgs.gemini-cli
    eza
    duf
  ];

  programs.bash.shellAliases = {
    nh-push = "/home/death916/nixconfig/scripts/nh-push";
    l = "eza -alh --icons";

  };

}
