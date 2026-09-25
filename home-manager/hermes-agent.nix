{ config, lib, pkgs, ... }:

let
  unmanaged = pkgs.writeText "hermes-managed" "false";
in
{
  programs.hermes-agent.enable = true;

  services.hermes-agent = {
    enable = true;
    gateway.enable = true;
    environmentFiles = [ "/home/death916/.hermes/hermes.env" ];
  };

  systemd.user.services.hermes-agent.Service.Environment = lib.mkAfter [ "HERMES_MANAGED=false" ];

  home.activation.hermesUnmanaged = lib.hm.dag.entryAfter [ "hermesAgentSetup" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -m 0600 ${unmanaged} ${config.home.homeDirectory}/.hermes/.managed
  '';
}
