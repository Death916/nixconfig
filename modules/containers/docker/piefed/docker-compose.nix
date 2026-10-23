# PieFed stack -- declarative port of ~/docker/compose/piefed/pyfedi/compose.yaml
#
# Why this exists: the stack was raw `docker compose up -d`, so nothing in Nix
# knew about it. On 2026-10-21 a `switch-to-configuration` restart of the docker
# units tore down /mnt/myjfs (JuiceFS is itself a container) and the compose
# stack lost the race to its own volume mount:
#   error while creating mount source path '/mnt/myjfs/piefed/media':
#   mkdir /mnt/myjfs: file exists
# web/celery/cron never came back and piefed served 504s for two days.
# Here every container that touches media is ordered after
# docker-myjfs-mount-service AND waits for the mount to exist before exec.
#
# Image builds: web/celery/cron/notifs are built from the upstream Dockerfile
# (^/app, python:3.13-alpine, pip). They are pip installs, not nix builds, so
# `docker-piefed-build.service` owns the build and the containers run the
# resulting local images with pull = "never". That unit never touches upstream
# git and is NOT an updater: it only builds when an image is missing, so a
# switch on a healthy box does nothing.
#
# Updating upstream code stays manual, exactly as before (do NOT use
# deploy-docker2.sh -- its `git pull` cannot work on this checkout, see below):
#   cd ~/docker/compose/piefed/pyfedi
#   git fetch origin && git rebase origin/v1.6.x     # branch "updates" has no
#                                                    # upstream and carries a
#                                                    # local cherry-pick, so
#                                                    # it never fast-forwards
#   sudo systemctl restart docker-piefed-build       # rebuild 4 app images
#   sudo systemctl restart docker-piefed-web docker-piefed-celery \
#        docker-piefed-cron docker-piefed-notifs
#
# Migration (one time):
#   cd ~/docker/compose/piefed/pyfedi && docker compose down
#   sudo install -m 400 -o root -g root .env.docker /etc/nixos/secrets/piefed.env
# then nixos-rebuild switch. All state stays on the same bind mounts
# (/var/lib/piefed/{db,redis,logs,tmp}, /mnt/myjfs/piefed/media), so nothing moves.

{ config, pkgs, lib, ... }:

let
  # Secret is read in place (a plain string, not a nix path) so the env file is
  # never copied into /nix/store.
  envFile = "/etc/nixos/secrets/piefed.env";

  # Upstream checkout the app images are built from.
  srcDir = "/home/death916/docker/compose/piefed/pyfedi";

  appImages = [
    "pyfedi-web:latest"
    "pyfedi-celery:latest"
    "pyfedi-cron:latest"
    "pyfedi-piefed-notifs:latest"
  ];

  mediaVolumes = [
    "/mnt/myjfs/piefed/media/:/app/app/static/media/:rw"
    "/var/lib/piefed/logs/:/app/logs/:rw"
    "/var/lib/piefed/tmp/:/app/app/static/tmp/:rw"
  ];

  # Type=simple means "container started", not "FUSE mount is answering", so
  # ordering alone is not enough. Block until the mount really exists.
  waitForMedia = pkgs.writeShellScript "piefed-wait-myjfs" ''
    i=0
    while [ "$i" -lt 90 ]; do
      if ${pkgs.util-linux}/bin/mountpoint -q /mnt/myjfs; then
        exit 0
      fi
      i=$((i + 1))
      sleep 2
    done
    echo "piefed: /mnt/myjfs still not mounted after 180s, refusing to start" >&2
    exit 1
  '';

  # Pure flake evaluation cannot stat /etc/..., so the env file is checked at
  # start time instead of with an assertion.
  checkEnv = pkgs.writeShellScript "piefed-check-env" ''
    if [ ! -r ${envFile} ]; then
      echo "piefed: ${envFile} is missing or unreadable" >&2
      echo "  sudo install -m 400 -o root -g root ${srcDir}/.env.docker ${envFile}" >&2
      exit 1
    fi
  '';

  commonUnit = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
      ExecStartPre = [ checkEnv ];
    };
    partOf = [ "docker-compose-piefed-root.target" ];
    wantedBy = [ "docker-compose-piefed-root.target" ];
  };

  # Containers whose image is built locally by docker-piefed-build.
  builtAppUnit = commonUnit // {
    serviceConfig = commonUnit.serviceConfig // {
      ExecStartPre = [ checkEnv waitForMedia ];
    };
    unitConfig.RequiresMountsFor = "/mnt/myjfs";
    after = [
      "docker-network-pf_network.service"
      "docker-myjfs-mount-service.service"
      "docker-piefed-build.service"
    ];
    requires = [
      "docker-network-pf_network.service"
      "docker-myjfs-mount-service.service"
      "docker-piefed-build.service"
    ];
  };

  # Image is pulled from a registry, no media mount needed.
  pulledUnit = commonUnit // {
    after = [ "docker-network-pf_network.service" ];
    requires = [ "docker-network-pf_network.service" ];
  };
in
{
  virtualisation.oci-containers.backend = "docker";

  virtualisation.oci-containers.containers = {

    # Registry images (db, redis) keep the default pull = "missing": pull =
    # "always" only fires when the unit restarts, so it would silently swap the
    # database image during an unrelated rebuild instead of on a schedule.
    # Refresh them deliberately (`docker pull postgres:17` then
    # `systemctl restart docker-piefed-db`) -- same major, so no pg_upgrade.

    # ---------------------------------------------------------------- database
    piefed-db = {
      image = "postgres:17";
      user = "1000:1000";
      environmentFiles = [ envFile ];
      cmd = [
        "postgres"
        # memory
        "-c" "shared_buffers=1GB"
        "-c" "effective_cache_size=2GB"
        "-c" "work_mem=32MB"
        "-c" "maintenance_work_mem=256MB"
        # wal / checkpoints
        "-c" "checkpoint_completion_target=0.9"
        "-c" "wal_buffers=16MB"
        "-c" "max_wal_size=3GB"
        "-c" "min_wal_size=1GB"
        # planner
        "-c" "random_page_cost=1.1"
        "-c" "effective_io_concurrency=200"
        # connections
        "-c" "max_connections=150"
        "-c" "jit=off"
      ];
      volumes = [ "/var/lib/piefed/db:/var/lib/postgresql/data:rw" ];
      networks = [ "pf_network" ];
      log-driver = "journald";
      extraOptions = [ "--shm-size=2gb" ];
    };

    # ------------------------------------------------------------------- cache
    piefed-redis = {
      image = "redis:6.2";
      environmentFiles = [ envFile ];
      volumes = [ "/var/lib/piefed/redis:/data:rw" ];
      networks = [ "pf_network" ];
      log-driver = "journald";
    };

    # --------------------------------------------------------------- web (8030)
    piefed-web = {
      image = "pyfedi-web:latest";
      pull = "never";
      dependsOn = [ "piefed-db" "piefed-redis" ];
      environmentFiles = [ envFile ];
      volumes = [
        "${srcDir}/gunicorn.conf.py:/app/gunicorn.conf.py:ro"
      ] ++ mediaVolumes;
      ports = [ "8030:5000/tcp" ];
      networks = [ "pf_network" ];
      log-driver = "journald";
      extraOptions = [
        "--health-cmd=pgrep -f gunicorn"
        "--health-interval=30s"
        "--health-timeout=10s"
        "--health-retries=3"
        "--health-start-period=20s"
      ];
    };

    # ------------------------------------------------------------ celery worker
    piefed-celery = {
      image = "pyfedi-celery:latest";
      pull = "never";
      dependsOn = [ "piefed-db" "piefed-redis" ];
      environmentFiles = [ envFile ];
      # --entrypoint wants an absolute path, so go through sh with the
      # image's WORKDIR (/app) intact.
      entrypoint = "/bin/sh";
      cmd = [ "-c" "exec ./entrypoint_celery.sh" ];
      volumes = mediaVolumes;
      networks = [ "pf_network" ];
      log-driver = "journald";
      extraOptions = [
        "--health-cmd=celery -A celery_worker_docker.celery inspect ping"
        "--health-interval=30s"
        "--health-timeout=10s"
        "--health-retries=3"
        "--health-start-period=20s"
      ];
    };

    # ------------------------------------------------------------- cron (root)
    piefed-cron = {
      image = "pyfedi-cron:latest";
      pull = "never";
      dependsOn = [ "piefed-db" "piefed-redis" ];
      environmentFiles = [ envFile ];
      user = "root";
      entrypoint = "/bin/sh";
      cmd = [
        "-c"
        ''
          cat > /etc/crontabs/python <<'CRON'
          5 2 * * * cd /app && export FLASK_APP=pyfedi.py && flask daily-maintenance
          5 4 * * 1 cd /app && export FLASK_APP=pyfedi.py && flask remove-orphan-files
          1 */6 * * * cd /app && export FLASK_APP=pyfedi.py && flask email-notifs
          */5 * * * * cd /app && export FLASK_APP=pyfedi.py && flask send-queue
          CRON
          exec crond -f -l 2
        ''
      ];
      volumes = mediaVolumes;
      networks = [ "pf_network" ];
      log-driver = "journald";
    };

    # ----------------------------------------------------------- notifs (8040)
    piefed-notifs = {
      image = "pyfedi-piefed-notifs:latest";
      pull = "never";
      dependsOn = [ "piefed-redis" ];
      environmentFiles = [ envFile ];
      entrypoint = "/bin/sh";
      cmd = [ "-c" "exec ./entrypoint_async.sh" ];
      ports = [ "8040:8000/tcp" ];
      networks = [ "pf_network" ];
      log-driver = "journald";
      extraOptions = [
        "--health-cmd=pgrep -f uvicorn"
        "--health-interval=30s"
        "--health-timeout=10s"
        "--health-retries=3"
        "--health-start-period=20s"
      ];
    };

    # adminer deliberately NOT declared: it was the only PHP on this host, it
    # is just a Postgres web UI, and nothing in the stack depends on it
    # (compose had no depends_on -> adminer). Use psql over the tailnet instead.

  };

  # ------------------------------------------------------------------ systemd
  systemd.services = {

    "docker-piefed-db" = pulledUnit;
    "docker-piefed-redis" = pulledUnit;

    "docker-piefed-web" = builtAppUnit;
    "docker-piefed-celery" = builtAppUnit;
    "docker-piefed-cron" = builtAppUnit;

    # notifs talks to redis only, never touches media.
    "docker-piefed-notifs" = commonUnit // {
      after = [
        "docker-network-pf_network.service"
        "docker-piefed-build.service"
      ];
      requires = [
        "docker-network-pf_network.service"
        "docker-piefed-build.service"
      ];
    };

    # Builds the four app images from the upstream checkout. No-op once they
    # exist, so a normal switch does not pay for a rebuild.
    "docker-piefed-build" = {
      description = "Build PieFed app images from ${srcDir}";
      path = [ config.virtualisation.docker.package ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = "30min";
      };
      script = ''
        missing=0
        ${lib.concatMapStringsSep "\n" (img: ''
          docker image inspect ${img} >/dev/null 2>&1 || missing=1
        '') appImages}
        if [ "$missing" -eq 0 ]; then
          echo "piefed: app images already built, skipping"
          exit 0
        fi
        cd ${srcDir}
        docker compose build
      '';
      partOf = [ "docker-compose-piefed-root.target" ];
      wantedBy = [ "docker-compose-piefed-root.target" ];
    };

    # Network compose used to create for us.
    "docker-network-pf_network" = {
      path = [ pkgs.docker ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStop = "docker network rm -f pf_network";
      };
      script = ''
        docker network inspect pf_network || docker network create pf_network
      '';
      partOf = [ "docker-compose-piefed-root.target" ];
      wantedBy = [ "docker-compose-piefed-root.target" ];
    };
  };

  systemd.targets."docker-compose-piefed-root" = {
    unitConfig.Description = "PieFed stack (declarative)";
    wantedBy = [ "multi-user.target" ];
  };
}
