{ config, lib, pkgs, ... }:

let
  cfg = config.services.abs-bookorbit-sync;
  pythonEnv = pkgs.python3.withPackages (ps: [ ps.psycopg2 ]);
  syncScript = pkgs.writeShellScriptBin "abs-bookorbit-sync" ''
    exec ${pythonEnv}/bin/python3 ${../pkgs/abs-bookorbit-sync/abs_to_bookorbit_sync.py} "$@"
  '';
in
{
  options.services.abs-bookorbit-sync = {
    enable = lib.mkEnableOption "Audiobookshelf to BookOrbit progress and session sync service";

    environmentFile = lib.mkOption {
      type = lib.types.path;
      default = "/etc/nixos/secrets/bookorbit.env";
      description = "Path to environment file containing POSTGRES_PASSWORD and database configuration.";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "*:0/15";
      description = "systemd OnCalendar schedule expression for periodic synchronization.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.abs-bookorbit-sync = {
      description = "Audiobookshelf to BookOrbit progress and session sync";
      after = [ "docker-bookorbit-db.service" "audiobookshelf.service" ];
      wants = [ "docker-bookorbit-db.service" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${syncScript}/bin/abs-bookorbit-sync";
        User = "root";
        EnvironmentFile = cfg.environmentFile;
        Environment = [
          "PYTHONUNBUFFERED=1"
          "POSTGRES_PORT=5422"
          "POSTGRES_HOST=127.0.0.1"
          "POSTGRES_USER=bookorbit"
          "POSTGRES_DB=bookorbit"
        ];
      };
    };

    systemd.timers.abs-bookorbit-sync = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.interval;
        Persistent = true;
      };
    };
  };
}
