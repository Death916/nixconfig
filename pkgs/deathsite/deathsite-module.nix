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

      environment = {
        API_URL = "https://${cfg.domain}";
        REFLEX_USE_SYSTEM_BUN = "True";
        PYTHONPATH = "/var/lib/deathsite";
        KEYS_PATH = "/var/lib/deathsite/keys.json";
      };

      serviceConfig = {
        Type = "simple";
        User = "deathsite";
        Group = "deathsite";
        WorkingDirectory = "/var/lib/deathsite";
        
        ExecStartPre = pkgs.writeShellScript "deathsite-setup" ''
          if [ ! -d "/var/lib/deathsite/.git" ]; then
            ${pkgs.git}/bin/git clone https://github.com/death916/deathsite.git /var/lib/deathsite
            chown -R deathsite:deathsite /var/lib/deathsite
          fi
          
          cd /var/lib/deathsite
          ${pkgs.git}/bin/git pull origin main
          ${pkgs.python311Packages.uv}/bin/uv sync --frozen
        '';

        ExecStart = "${pkgs.python311Packages.uv}/bin/uv run reflex run --env prod --single-port --frontend-port ${toString cfg.port}";
        
        Restart = "always";
        RestartSec = "10";
        StateDirectory = "deathsite";
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
