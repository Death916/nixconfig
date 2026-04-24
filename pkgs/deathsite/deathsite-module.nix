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

      serviceConfig = {
        Type = "simple";
        User = "deathsite";
        Group = "deathsite";
        WorkingDirectory = "/var/lib/deathsite";
        StateDirectory = "deathsite";
        Restart = "always";
        RestartSec = "10";

        # Use + to run as root to fix git/permissions
        ExecStartPre = [
          "+${pkgs.writeShellScript "deathsite-setup-root" ''
            if [ ! -d "/var/lib/deathsite/.git" ]; then
              cd /var/lib/deathsite
              ${pkgs.git}/bin/git init
              ${pkgs.git}/bin/git remote add origin https://github.com/death916/deathsite.git
              ${pkgs.git}/bin/git fetch origin
              ${pkgs.git}/bin/git reset --hard origin/main
            fi
            
            cd /var/lib/deathsite
            ${pkgs.git}/bin/git pull origin main
            chown -R deathsite:deathsite /var/lib/deathsite
          ''}"
          "${pkgs.writeShellScript "deathsite-setup-user" ''
            cd /var/lib/deathsite
            ${pkgs.python311Packages.uv}/bin/uv sync --frozen
          ''}"
        ];

        ExecStart = "${pkgs.python311Packages.uv}/bin/uv run reflex run --env prod --single-port --frontend-port ${toString cfg.port}";
      };

      environment = {
        HOME = "/var/lib/deathsite";
        API_URL = "https://${cfg.domain}";
        REFLEX_USE_SYSTEM_BUN = "True";
        PYTHONPATH = "/var/lib/deathsite";
        KEYS_PATH = "/var/lib/deathsite/keys.json";
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
