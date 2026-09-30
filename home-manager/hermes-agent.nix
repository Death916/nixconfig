{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  unmanaged = pkgs.writeText "hermes-managed" "false";

  hindsight-hermes = pkgs.stdenv.mkDerivation {
    pname = "hindsight-hermes";
    version = "1.2.1";
    src = "${inputs.hindsight}/hindsight-integrations/hermes";
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      cp -r . $out/
    '';
  };
in
{
  programs.hermes-agent.enable = true;

  services.hermes-agent = {
    enable = true;
    gateway.enable = true;
    environmentFiles = [ "/home/death916/.hermes/hermes.env" ];
    extraPlugins = [ hindsight-hermes ];
  };

  systemd.user.services.hermes-agent.Service.Environment = lib.mkAfter [ "HERMES_MANAGED=false" ];

  home.activation.hermesUnmanaged = lib.hm.dag.entryAfter [ "hermesAgentSetup" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -m 0600 ${unmanaged} ${config.home.homeDirectory}/.hermes/.managed
  '';
}
