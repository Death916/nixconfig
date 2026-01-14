{ config, pkgs, lib, ... }:

{
  virtualisation.oci-containers.containers = {
    immich-server = {
      image = "ghcr.io/immich-app/immich-server:release";
      volumes = [
        "/storage/services/immich/upload:/data"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environmentFiles = [ "/etc/nixos/secrets/immich.env" ];
      ports = [ "2283:2283" ];
      dependsOn = [ "immich-redis" "immich-machine-learning" ];
      extraFlags = [ "--restart=always" ]; # Corrected way to set restart policy
      environment = {
        DB_HOSTNAME = "localhost";
        DB_PORT = "5432";
        DB_USERNAME = "immich";
        DB_DATABASE_NAME = "immich_db";
        REDIS_HOSTNAME = "immich-redis";
        REDIS_PORT = "6379";
        MACHINE_LEARNING_HOSTNAME = "immich-machine-learning";
        UPLOAD_LOCATION = "/data";
        TZ = "America/Los_Angeles";
      };
      user = "immich";
    };

    immich-machine-learning = {
      image = "ghcr.io/immich-app/immich-machine-learning:release";
      volumes = [
        "/storage/services/immich/model-cache:/cache"
      ];
      environmentFiles = [ "/etc/nixos/secrets/immich.env" ];
      extraFlags = [ "--restart=always" ]; # Corrected way to set restart policy
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
      image = "docker.io/valkey/valkey:9@sha256:fb8d272e529ea567b9bf1302245796f21a2672b8368ca3fcb938ac334e613c8f";
      volumes = [
        "/var/lib/immich/redis-data:/data"
      ];
      extraFlags = [ "--restart=always" ]; # Corrected way to set restart policy
      user = "redis"; # Standard Redis user for consistency/permissions
    };
  };
}
