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
    inputs.hermes-agent.packages.${pkgs.system}.default
  ];

  home.sessionVariables = {
    TERM = "xterm-256color";
  };

  programs.bash.shellAliases = {
    nh-push = "/home/death916/nixconfig/scripts/nh-push";
    l = "eza -alh --icons";
  };

  systemd.user.services.hermes-gateway = {
    Unit = {
      Description = "Hermes Agent Gateway - Messaging Platform Integration";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${inputs.hermes-agent.packages.${pkgs.system}.default}/bin/hermes gateway run";
      WorkingDirectory = "/home/death916/.hermes";
      Environment = [
        "HERMES_HOME=/home/death916/.hermes"
        "PATH=${pkgs.nodejs}/bin:/home/death916/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
      ];
      EnvironmentFile = "${config.home.homeDirectory}/.hermes/hermes.env";
      Restart = "always";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
