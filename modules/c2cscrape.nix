{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.c2cscrape;
  # Import the package relative to this file
  c2cscrapePkg = pkgs.python3Packages.callPackage ../pkgs/c2cscrape/default.nix {
    qbittorrentApi = pkgs.python3Packages.qbittorrent-api;
    pythonDotenv = pkgs.python3Packages.python-dotenv;
  };
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
  };

  config = lib.mkIf cfg.enable {
    # 1. The Service
    systemd.services.c2cscrape = {
      description = "Coast 2 Coast Scraper Service";
      unitConfig.RequiresMountsFor = cfg.dataDir;

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${c2cscrapePkg}/bin/c2cscrape";
        User = cfg.user;
        WorkingDirectory = cfg.dataDir;
        Environment = "PYTHONUNBUFFERED=1";

      };
    };

    systemd.timers.c2cscrape = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "5m";
      };
    };
  };
}
