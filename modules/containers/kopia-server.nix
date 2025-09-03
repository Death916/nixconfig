{
  config,
  pkgs,
  lib,
  ...
}:

let
  # All settings are defined here for easy editing
  secretsFile = "/etc/nixos/secrets/kopia.env";
  tlsCert = "/var/lib/kopia/homelab.bandicoot-skate.ts.net.crt";
  tlsKey = "/var/lib/kopia/homelab.bandicoot-skate.ts.net.key";
  listenAddress = "0.0.0.0:51515";
  dataDir = "/var/lib/kopia";
in
{
  options.services.kopia-server.enable = lib.mkEnableOption "Self-contained Kopia Server";

  config = lib.mkIf config.services.kopia-server.enable {
    systemd.services.kopia-server = {
      description = "Kopia Backup Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      environment = {
        KOPIA_CONFIG_PATH = "${dataDir}/repository.config";
        KOPIA_LOG_DIR = "${dataDir}/logs";
        KOPIA_CACHE_DIRECTORY = "${dataDir}/cache";
      };

      serviceConfig = {
        Type = "simple";
        User = "root";
        EnvironmentFile = secretsFile;
        ExecStart = ''
          ${pkgs.kopia}/bin/kopia server start --disable-csrf-token-checks --address=${listenAddress} --tls-cert-file=${tlsCert} --tls-key-file=${tlsKey}
        '';
        Restart = "on-failure";
        ReadWritePaths = [ dataDir ];
      };

      preStart = "mkdir -p ${dataDir}";
    };
  };
}
