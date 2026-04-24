{ config, pkgs, lib, ... }:

let
  cfg = config.services.deathsite;
in
{
  options.services.deathsite = {
    enable = lib.mkEnableOption "Deathsite Reflex App";
    domain = lib.mkOption {
      type = lib.types.str;
      default = "death916.xyz";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.deathsite = {
      description = "Deathsite Reflex Application Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [
        bun
        python311
        python311Packages.uv
        git
      ];

      serviceConfig = {
        Type = "simple";
        User = "death916";
        Group = "users";
        WorkingDirectory = "/home/death916/prod/deathsite";
        Restart = "always";
        RestartSec = "10";

        ExecStart = "${pkgs.python311Packages.uv}/bin/uv run reflex run --env prod --single-port --frontend-port ${toString cfg.port}";
      };

      environment = {
        HOME = "/home/death916";
        API_URL = "https://${cfg.domain}";
        REFLEX_USE_SYSTEM_BUN = "True";
        PYTHONPATH = "/home/death916/prod/deathsite";
        KEYS_PATH = "/home/death916/prod/deathsite/deathsite/keys.json";
      };
    };

    users.users.deathsite = {
      isSystemUser = true;
      group = "deathsite";
      home = "/var/lib/deathsite";
      createHome = true;
    };
    users.groups.deathsite = {};
    
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
