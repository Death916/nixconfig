{ config, pkgs, ... }:

{
  virtualisation.oci-containers.containers = {
    immich-server = {
      image = "ghcr.io/immich-app/immich-server:release";
      ports = [ "2283:2283" ];
      volumes = [
        "/storage/services/immich/upload:/data"
        "/etc/localtime:/etc/localtime:ro"
      ];
      user = "immich";
      environment = {
        DB_HOSTNAME = "localhost";
        DB_PORT = "5432";
        DB_USERNAME = "immich";
        DB_DATABASE_NAME = "immich_db";
        REDIS_HOSTNAME = "immich-redis";
        REDIS_PORT = "6379";
        MACHINE_LEARNING_HOSTNAME = "immich-machine-learning";
      };
      environmentFiles = [ "/etc/nixos/secrets/immich.env" ];
      dependsOn = [ "immich-redis" "immich-machine-learning" ];
      autoStart = true;
    };

    immich-machine-learning = {
      image = "ghcr.io/immich-app/immich-machine-learning:release";
      volumes = [
        "/storage/services/immich/model-cache:/cache"
      ];
      user = "immich";
      environment = {
        REDIS_HOSTNAME = "immich-redis";
        REDIS_PORT = "6379";
        DB_HOSTNAME = "localhost";
        DB_PORT = "5432";
        DB_USERNAME = "immich";
        DB_DATABASE_NAME = "immich_db";
      };
      environmentFiles = [ "/etc/nixos/secrets/immich.env" ];
      autoStart = true;
    };

    immich-redis = {
      image = "redis:latest";
      volumes = [
        "/storage/services/immich/redis-data:/data"
      ];
      autoStart = true;
    };
  };
}
