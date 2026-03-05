{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.piefed;
  
  # local callPackage pattern from c2cscrape
  piefedPkg = pkgs.python3Packages.callPackage ../../pkgs/piefed/default.nix {
    tesseract = pkgs.tesseract;
    # Custom python packages need to be passed if not automatically resolved
  };

  # Helper to run piefed commands
  piefedManage = pkgs.writeShellScriptBin "piefed-manage" ''
    export FLASK_APP=pyfedi.py
    export PYTHONPATH=${piefedPkg}/opt/piefed
    export EnvironmentFile=${cfg.environmentFile}
    cd ${piefedPkg}/opt/piefed
    # Use environment variables from cfg.environmentFile if possible, 
    # but for simple CLI we might need to source it or use 'env'
    exec ${pkgs.python3}/bin/python3 -m flask "$@"
  '';
in
{
  options.services.piefed = {
    enable = mkEnableOption "PieFed";
    domain = mkOption {
      type = types.str;
      description = "The domain name for the instance";
    };
    environmentFile = mkOption {
      type = types.path;
      description = "Path to the .env file containing secrets";
    };
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/piefed";
      description = "Directory to store media, uploads, and logs";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "piefed" ];
      ensureUsers = [{
        name = "piefed";
        ensureDBOwnership = true;
      }];
    };

    services.redis.servers.piefed = {
      enable = true;
      port = 6379;
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 piefed piefed -"
      "d ${cfg.dataDir}/media 0750 piefed piefed -"
      "d ${cfg.dataDir}/logs 0750 piefed piefed -"
      "d ${cfg.dataDir}/tmp 0750 piefed piefed -"
    ];

    users.users.piefed = {
      isSystemUser = true;
      group = "piefed";
      home = cfg.dataDir;
    };
    users.groups.piefed = { };

    systemd.services.piefed-web = {
      description = "PieFed Web Service";
      after = [ "network.target" "postgresql.service" "redis-piefed.service" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        FLASK_APP = "pyfedi.py";
        PYTHONPATH = "${piefedPkg}/opt/piefed";
        PIEFED_MEDIA_PATH = "${cfg.dataDir}/media";
        PIEFED_LOG_PATH = "${cfg.dataDir}/logs";
      };
      serviceConfig = {
        User = "piefed";
        Group = "piefed";
        WorkingDirectory = "${piefedPkg}/opt/piefed";
        EnvironmentFile = cfg.environmentFile;
        ExecStart = "${pkgs.python3Packages.gunicorn}/bin/gunicorn --config ${piefedPkg}/opt/piefed/gunicorn.conf.py --preload pyfedi:app";
        Restart = "always";
      };
    };

    systemd.services.piefed-worker = {
      description = "PieFed Celery Worker";
      after = [ "piefed-web.service" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        PYTHONPATH = "${piefedPkg}/opt/piefed";
      };
      serviceConfig = {
        User = "piefed";
        Group = "piefed";
        WorkingDirectory = "${piefedPkg}/opt/piefed";
        EnvironmentFile = cfg.environmentFile;
        ExecStart = "${pkgs.python3Packages.celery}/bin/celery -A celery_worker.celery worker --loglevel=INFO";
        Restart = "always";
      };
    };

    systemd.services.piefed-notifs = {
      description = "PieFed Notifications Service";
      after = [ "piefed-web.service" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        PYTHONPATH = "${piefedPkg}/opt/piefed";
      };
      serviceConfig = {
        User = "piefed";
        Group = "piefed";
        WorkingDirectory = "${piefedPkg}/opt/piefed";
        EnvironmentFile = cfg.environmentFile;
        ExecStart = "${pkgs.python3Packages.uvicorn}/bin/uvicorn fastapi_server:app --host 127.0.0.1 --port 8040";
        Restart = "always";
      };
    };

    # Migration one-shot service
    systemd.services.piefed-migrate = {
      description = "PieFed Database Migrations";
      after = [ "postgresql.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "piefed";
        Group = "piefed";
        WorkingDirectory = "${piefedPkg}/opt/piefed";
        EnvironmentFile = cfg.environmentFile;
        ExecStart = "${piefedManage}/bin/piefed-manage db upgrade";
        RemainAfterExit = true;
      };
    };
  };
}
