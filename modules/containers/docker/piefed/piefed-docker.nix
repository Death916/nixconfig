{
  config,
  pkgs,
  lib,
  ...
}:

let
  piefedAppSrc = pkgs.fetchFromGitea {
    domain = "codeberg.org";
    owner = "rimu";
    repo = "pyfedi";
    rev = "v1.5.x"; # Replace with target release branch (e.g., v1.5.x or main)
    hash = lib.fakeHash;
  };

  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      flask
      gunicorn
      celery
      psycopg2
      redis
      requests
      python-dotenv
      authlib
      beautifulsoup4
      pillow
      flask-migrate
      flask-sqlalchemy
    ]
  );

  piefedImage = pkgs.dockerTools.buildLayeredImage {
    name = "piefed";
    tag = "nix-latest";
    contents = [
      pythonEnv
      pkgs.bash
      pkgs.coreutils
      pkgs.findutils
      pkgs.curl
    ];

    extraCommands = ''
      mkdir -p app
      cp -r ${piefedAppSrc}/* app/
      chmod -R +w app/ # Ensure app directory is writable for setup scripts
    '';

    config = {
      Cmd = [
        "${pythonEnv}/bin/gunicorn"
        "-w"
        "4"
        "-b"
        "0.0.0.0:5000"
        "pyfedi:app"
      ];
      WorkingDir = "/app";
      Env = [
        "FLASK_APP=pyfedi.py"
        "PYTHONUNBUFFERED=1"
      ];
    };
  };

in
{
  virtualisation.oci-containers.backend = "docker";

  systemd.tmpfiles.rules = [
    "d /var/lib/piefed 0755 root root -"
    "d /var/lib/piefed/pgdata 0700 root root -"
    "d /var/lib/piefed/redis 0700 root root -"
    "d /var/lib/piefed/media 0755 root root -"
    "d /var/lib/piefed/logs 0755 root root -"
    "d /var/lib/piefed/tmp 0755 root root -"
  ];

  systemd.services.docker-network-piefed = {
    description = "Create Docker Network for PieFed";
    after = [
      "network.target"
      "docker.service"
    ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.docker}/bin/docker network inspect piefed-net >/dev/null 2>&1 || \
      ${pkgs.docker}/bin/docker network create piefed-net
    '';
  };

  virtualisation.oci-containers.containers = {

    piefed-db = {
      image = "postgres:15-alpine";
      environmentFiles = [ "/var/lib/piefed/.env.docker" ]; # SECRETS LOADED HERE
      volumes = [ "/var/lib/piefed/pgdata:/var/lib/postgresql/data" ];
      extraOptions = [ "--network=piefed-net" ];
    };

    piefed-redis = {
      image = "redis:7-alpine";
      volumes = [ "/var/lib/piefed/redis:/data" ];
      extraOptions = [ "--network=piefed-net" ];
    };

    piefed-web = {
      image = "piefed:nix-latest";
      imageFile = piefedImage; # Nix auto-loads the tarball into Docker!
      ports = [ "8030:5000" ];
      environmentFiles = [ "/var/lib/piefed/.env.docker" ]; # SECRETS LOADED HERE
      volumes = [
        "/var/lib/piefed/media:/app/media"
        "/var/lib/piefed/logs:/app/logs"
        "/var/lib/piefed/tmp:/app/tmp"
      ];
      dependsOn = [
        "piefed-db"
        "piefed-redis"
      ];
      extraOptions = [ "--network=piefed-net" ];
    };

    piefed-worker = {
      image = "piefed:nix-latest";
      cmd = [
        "${pythonEnv}/bin/celery"
        "-A"
        "pyfedi.celery"
        "worker"
        "-l"
        "info"
      ];
      environmentFiles = [ "/var/lib/piefed/.env.docker" ];
      volumes = [
        "/var/lib/piefed/media:/app/media"
        "/var/lib/piefed/logs:/app/logs"
        "/var/lib/piefed/tmp:/app/tmp"
      ];
      dependsOn = [
        "piefed-db"
        "piefed-redis"
      ];
      extraOptions = [ "--network=piefed-net" ];
    };
  };

  systemd.services."docker-piefed-db".requires = [ "docker-network-piefed.service" ];
  systemd.services."docker-piefed-redis".requires = [ "docker-network-piefed.service" ];
  systemd.services."docker-piefed-web".requires = [ "docker-network-piefed.service" ];
  systemd.services."docker-piefed-worker".requires = [ "docker-network-piefed.service" ];

  systemd.services.piefed-daily = {
    script = "${pkgs.docker}/bin/docker exec piefed-web bash -c 'cd /app && ./daily.sh'";
    serviceConfig.Type = "oneshot";
  };
  systemd.timers.piefed-daily = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 02:05:00";
      Persistent = true;
    };
  };

  systemd.services.piefed-orphan-files = {
    script = "${pkgs.docker}/bin/docker exec piefed-web bash -c 'cd /app && ./remove_orphan_files.sh'";
    serviceConfig.Type = "oneshot";
  };
  systemd.timers.piefed-orphan-files = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Mon *-*-* 04:05:00";
      Persistent = true;
    };
  };

  systemd.services.piefed-email-notifs = {
    script = "${pkgs.docker}/bin/docker exec piefed-web bash -c 'cd /app && ./email_notifs.sh'";
    serviceConfig.Type = "oneshot";
  };
  systemd.timers.piefed-email-notifs = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 00/6:01:00";
      Persistent = true;
    };
  };

  systemd.services.piefed-send-queue = {
    script = "${pkgs.docker}/bin/docker exec piefed-web bash -c 'cd /app && ./send_queue.sh'";
    serviceConfig.Type = "oneshot";
  };
  systemd.timers.piefed-send-queue = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/5";
      Persistent = true;
    };
  };
}
