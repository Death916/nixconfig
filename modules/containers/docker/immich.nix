{ config, pkgs, lib, ... }:

{
  virtualisation.oci-containers.containers = {
    immich-server = {
      container_name = "immich_server";
      image = "ghcr.io/immich-app/immich-server:release";
      volumes = [
        "/storage/services/immich/upload:/data" # Heavy data on HDD
        "/etc/localtime:/etc/localtime:ro"
      ];
      environmentFiles = [ "/etc/nixos/secrets/immich.env" ];
      ports = [ "2283:2283" ];
      dependsOn = [ "immich-redis" "immich-machine-learning" ];
      restart = "always";
      healthcheck.disable = false;
      environment = {
        DB_HOSTNAME = "localhost";
        DB_PORT = "5432";
        DB_USERNAME = "immich";
        DB_DATABASE_NAME = "immich_db";
        REDIS_HOSTNAME = "immich-redis";
        REDIS_PORT = "6379";
        MACHINE_LEARNING_HOSTNAME = "immich-machine-learning";
        UPLOAD_LOCATION = "/data"; # Internal path in container
        TZ = "America/Los_Angeles";
      };
      user = "immich";
    };

    immich-machine-learning = {
      container_name = "immich_machine_learning";
      image = "ghcr.io/immich-app/immich-machine-learning:release";
      volumes = [
        "/storage/services/immich/model-cache:/cache" # Heavy data on HDD
      ];
      environmentFiles = [ "/etc/nixos/secrets/immich.env" ];
      restart = "always";
      healthcheck.disable = false;
      environment = {
        REDIS_HOSTNAME = "immich-redis";
        REDIS_PORT = "6379";
        DB_HOSTNAME = "localhost";
        DB_PORT = "5432";
        DB_USERNAME = "immich";
        DB_DATABASE_NAME = "immich_db";
        TZ = "America/Los_Angeles";
      };
      user = "immich";
    };

    immich-redis = {
      container_name = "immich_redis";
      image = "docker.io/valkey/valkey:9@sha256:fb8d272e529ea567b9bf1302245796f21a2672b8368ca3fcb938ac334e613c8f";
      volumes = [
        "/var/lib/immich/redis-data:/data" # Smaller, performance-critical data on SSD
      ];
      restart = "always";
      healthcheck.test = [ "redis-cli" "ping" "||" "exit" "1" ];
    };
  };
}