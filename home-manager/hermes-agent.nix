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
      printf '\npython_runtime: external\n' >> $out/plugin.yaml
    '';
  };

  hindsight-client = config.services.hermes-agent.package.python.pkgs.buildPythonPackage {
    pname = "hindsight-client";
    version = "0.10.2";
    src = "${inputs.hindsight}/hindsight-clients/python";
    pyproject = true;
    build-system = [ config.services.hermes-agent.package.python.pkgs.hatchling ];
    propagatedBuildInputs = [ ];
    dontCheckRuntimeDeps = true;
    doCheck = false;
  };
in
{
  programs.hermes-agent.enable = true;

  services.hermes-agent = {
    enable = true;
    gateway.enable = true;
    environmentFiles = [ "/home/death916/.hermes/hermes.env" ];
    extraPlugins = [ hindsight-hermes ];
    extraPythonPackages = [ hindsight-client ];
  };

  systemd.user.services.hermes-agent.Service.Environment = lib.mkAfter [ "HERMES_MANAGED=false" ];

  home.activation.hermesUnmanaged = lib.hm.dag.entryAfter [ "hermesAgentSetup" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -m 0600 ${unmanaged} ${config.home.homeDirectory}/.hermes/.managed
  '';
}
