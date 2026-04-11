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
  programs.bash.initExtra = ''
    export TERM=xterm-256color
  '';

  home.packages = with pkgs; [
    fastfetch
    wget
    zellij
    systemctl-tui
    unstablePkgs.gemini-cli
    eza
    duf
  ];

  home.sessionVariables = {
    TERM = "xterm-256color";
  };

  programs.bash.shellAliases = {
    nh-push = "/home/death916/nixconfig/scripts/nh-push";
    l = "eza -alh --icons";

  };

}
