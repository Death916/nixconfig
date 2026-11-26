{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.c2cscrape;
  c2cscrapePkg = pkgs.python3Packages.callPackage ../pkgs/c2cscrape/default.nix {
    qbittorrentApi = pkgs.python3Packages.qbittorrent-api;
    pythonDotenv = pkgs.python3Packages.python-dotenv;
  };

  fixPerms = pkgs.writeShellScript "c2cscrape-fix-perms" ''
    set -eu
    target=${lib.escapeShellArg (toString cfg.dataDir)}
    if [ ! -d "$target" ]; then
      exit 0
    fi
    ${pkgs.coreutils}/bin/chown -R ${cfg.user}:${cfg.group} "$target"
    ${pkgs.findutils}/bin/find "$target" -type d -exec ${pkgs.coreutils}/bin/chmod 2775 {} +
    ${pkgs.findutils}/bin/find "$target" -type f -exec ${pkgs.coreutils}/bin/chmod 0664 {} +
  '';
in
{
  options.services.c2cscrape = {
    enable = lib.mkEnableOption "C2C Scraper Service";

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/c2cscrape";
      description = "Directory where episodes will be saved.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "c2cscrape";
      description = "user to run as";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "media_services";
      description = "group to run as and to grant write access to dataDir";
    };

    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to an .env file ";
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. The Service
    systemd.services.c2cscrape = {
      description = "Coast 2 Coast Scraper Service";
      unitConfig.RequiresMountsFor = cfg.dataDir;

      serviceConfig = {
        Type = "oneshot";
        ExecStartPre = "+${fixPerms}";
        ExecStart = "${c2cscrapePkg}/bin/c2cscrape";
        User = cfg.user;
        Group = cfg.group;
        UMask = "0002";
        WorkingDirectory = cfg.dataDir;
        Environment = "PYTHONUNBUFFERED=1";
        EnvironmentFile = cfg.environmentFile;
      };
    };

    systemd.timers.c2cscrape = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        Persistent = true;
        RandomizedDelaySec = "30m";
      };
    };
  };
}
