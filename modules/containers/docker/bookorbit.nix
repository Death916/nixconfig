{
  config,
  pkgs,
  lib,
  ...
}:

{
  virtualisation.oci-containers.containers = {
    bookorbit-db = {
      image = "pgvector/pgvector:pg18";
      environment = {
        POSTGRES_USER = "bookorbit";
        POSTGRES_DB = "bookorbit";
        PGDATA = "/var/lib/postgresql/data/pgdata";
      };
      environmentFiles = [ "/etc/nixos/secrets/bookorbit.env" ];
      volumes = [
        "/storage/services/bookorbit/postgres:/var/lib/postgresql/data:rw"
      ];
      ports = [
        "0.0.0.0:5422:5432"
      ];
      extraOptions = [
        "--health-cmd=pg_isready -U \"$POSTGRES_USER\" -d \"$POSTGRES_DB\""
        "--health-interval=10s"
        "--health-timeout=5s"
        "--health-retries=10"
        "--health-start-period=20s"
      ];
      log-driver = "journald";
    };

    bookorbit-app = {
      image = "ghcr.io/bookorbit/bookorbit:latest";
      pull = "always";
      dependsOn = [ "bookorbit-db" ];
      environment = {
        NODE_ENV = "production";
        PORT = "3010";
        POSTGRES_HOST = "host.docker.internal";
        POSTGRES_PORT = "5422";
        POSTGRES_USER = "bookorbit";
        POSTGRES_DB = "bookorbit";
        TZ = "America/Los_Angeles";
        PUID = "1000";
        PGID = "1000";
        NODE_MAX_OLD_SPACE_SIZE = "2048";
        LIBRARY_BROWSE_ROOT = "/books";
      };
      environmentFiles = [ "/etc/nixos/secrets/bookorbit.env" ];
      volumes = [
        "/storage/services/bookorbit/app:/data:rw"
        "/media/storage/media/books/bookorbit:/books:rw"
      ];
      ports = [
        "3006:3010/tcp"
      ];
      extraOptions = [
        "--add-host=host.docker.internal:host-gateway"
        "--health-cmd=wget -q -T 4 -O /dev/null http://127.0.0.1:3010/api/v1/health || exit 1"
        "--health-interval=30s"
        "--health-timeout=5s"
        "--health-retries=3"
        "--health-start-period=20s"
      ];
      log-driver = "journald";
    };
  };

  systemd.services."docker-bookorbit-db" = {
    unitConfig = {
      RequiresMountsFor = [ "/storage" ];
      After = [ "storage.mount" ];
      Wants = [ "storage.mount" ];
    };
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartSec = lib.mkOverride 90 "5s";
    };
  };

  systemd.services."docker-bookorbit-app" = {
    after = [ "docker-bookorbit-db.service" ];
    requires = [ "docker-bookorbit-db.service" ];
    unitConfig = {
      RequiresMountsFor = [
        "/storage"
        "/media"
      ];
      After = [
        "storage.mount"
        "media.mount"
      ];
      Wants = [
        "storage.mount"
        "media.mount"
      ];
    };
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartSec = lib.mkOverride 90 "5s";
    };
  };

  systemd.tmpfiles.rules = [
    "d /storage/services/bookorbit 0755 root root -"
    "d /storage/services/bookorbit/app 0755 1000 1000 -"
    "d /storage/services/bookorbit/postgres 0700 999 999 -"
    "d /media/storage/media/books/bookorbit 0755 1000 1000 -"
  ];

  networking.firewall.allowedTCPPorts = [ 3006 ];
}
