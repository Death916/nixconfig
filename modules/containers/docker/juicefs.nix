# Auto-generated using compose2nix v0.3.1.
{ pkgs, lib, ... }:

{
  # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";

  # Containers
  virtualisation.oci-containers.containers."myjfs-mount-service" = {
    image = "juicedata/mount:ce-v1.2.1";
    volumes = [
      "/mnt/myjfs:/mnt/jfs:rw,rshared"
      "juice_juicefs_cache:/var/jfsCache:rw"
      "/etc/nixos/secrets/juicefs.env:/run/secrets/juicefs.env:ro"
    ];
    # The JuiceFS local block cache lives ON ROOT (/var/jfsCache is a docker
    # volume in /var/lib/docker) and is uncapped by default: --cache-size is
    # 100GiB and only --free-space-ratio stops it. At the default 0.1 it will
    # happily fill root down to ~9G free on this 91G disk. Measured 2026-10-14:
    # the 9.1G podcast mirror pushed this cache 110M -> 4.4G and root from 14G
    # free to 9.1G. Bounded deliberately here:
    #   --free-space-ratio 0.15 -> keep >=13.6G free on root (the real cap,
    #                              since ~70G of root is live data that cannot
    #                              move: docker 19G + /nix 32G + live DBs)
    #   --cache-expire 604800   -> clear cold blocks after 7 days (default 0 =
    #                              never expires, so one-off writes squat forever)
    # --cache-size is deliberately LEFT AT DEFAULT: the ratio is the binding
    # constraint, so capping size as well only costs read perf for no gain.
    # NOTE: compose2nix-generated file - re-check these flags after a regen.
    cmd = [
      "sh"
      "-c"
      ''
        . /run/secrets/juicefs.env &&         PGPASSWORD="$POSTGRES_PASSWORD" juicefs mount --attr-cache 10 --entry-cache 10 --prefetch 1 --open-cache 60 --buffer-size 300 --cache-dir /var/jfsCache --free-space-ratio 0.15 --cache-expire 604800 postgres://death916@postgres:5432/juicefs?sslmode=disable /mnt/jfs
      ''
    ];
    dependsOn = [
      "postgres-for-juicefs"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cap-add=SYS_ADMIN"
      "--device=/dev/fuse:/dev/fuse:rwm"
      "--network-alias=juicefs-mount"
      "--network=juice_default"
      "--security-opt=apparmor:unconfined"
      "--memory=2g"
    ];
  };
  systemd.services."docker-myjfs-mount-service" = {
    serviceConfig = {
      EnvironmentFile = "/etc/nixos/secrets/juicefs.env";
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-juice_default.service"
      "docker-volume-juice_juicefs_cache.service"
    ];
    requires = [
      "docker-network-juice_default.service"
      "docker-volume-juice_juicefs_cache.service"
    ];
    partOf = [
      "docker-compose-juice-root.target"
    ];
    wantedBy = [
      "docker-compose-juice-root.target"
    ];
  };
  virtualisation.oci-containers.containers."postgres-for-juicefs" = {
    image = "postgres:alpine";
    volumes = [
      "/home/death916/docker/volumes/postgres:/var/lib/postgresql/data:rw"
    ];
    ports = [
      "5430:5432/tcp"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=sh -c 'pg_isready -U death916 -d juicefs'"
      "--health-interval=10s"
      "--health-retries=5"
      "--health-timeout=5s"
      "--network-alias=postgres"
      "--network=juice_default"
    ];
  };
  systemd.services."docker-postgres-for-juicefs" = {
    serviceConfig = {
      EnvironmentFile = "/etc/nixos/secrets/juicefs.env";
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-juice_default.service"
    ];
    requires = [
      "docker-network-juice_default.service"
    ];
    partOf = [
      "docker-compose-juice-root.target"
    ];
    wantedBy = [
      "docker-compose-juice-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-juice_default" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f juice_default";
    };
    script = ''
      docker network inspect juice_default || docker network create juice_default
    '';
    partOf = [ "docker-compose-juice-root.target" ];
    wantedBy = [ "docker-compose-juice-root.target" ];
  };

  # Volumes
  systemd.services."docker-volume-juice_juicefs_cache" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      docker volume inspect juice_juicefs_cache || docker volume create juice_juicefs_cache
    '';
    partOf = [ "docker-compose-juice-root.target" ];
    wantedBy = [ "docker-compose-juice-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-juice-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
