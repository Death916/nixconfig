{ config, lib, pkgs, ... }:

let
  localDir = "/var/lib/piefed";
  mediaDir = "/mnt/myjfs/piefed/media";
in
{
  systemd.tmpfiles.rules = [
    "d ${localDir} 0755 root root -"
    "d ${localDir}/db 0700 1000 1000 -"
    "d ${localDir}/redis 0700 999 999 -"
    "d ${localDir}/logs 0755 1000 1000 -"
    "d ${localDir}/tmp 0755 1000 1000 -"
    "d ${mediaDir} 0755 1000 1000 -"
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      piefed-db = {
        image = "postgres:17";
        volumes = [ "${localDir}/db:/var/lib/postgresql/data" ];
        environmentFiles = [ "${localDir}/.env.docker" ];
        cmd = [
          "postgres"
          "-c" "shared_buffers=1GB"
          "-c" "effective_cache_size=2GB"
          "-c" "work_mem=32MB"
          "-c" "maintenance_work_mem=256MB"
          "-c" "checkpoint_completion_target=0.9"
          "-c" "wal_buffers=16MB"
          "-c" "max_wal_size=3GB"
          "-c" "min_wal_size=1GB"
          "-c" "random_page_cost=1.1"
          "-c" "effective_io_concurrency=200"
          "-c" "max_connections=150"
          "-c" "jit=off"
        ];
        extraOptions = [ "--shm-size=2gb" "--user=1000:1000" "--network=piefed_net" ];
      };

      piefed-redis = {
        image = "redis:6.2";
        volumes = [ "${localDir}/redis:/data" ];
        environmentFiles = [ "${localDir}/.env.docker" ];
        extraOptions = [ "--network=piefed_net" ];
      };

      piefed-web = {
        image = "elestio/piefed:latest";
        dependsOn = [ "piefed-db" "piefed-redis" ];
        environmentFiles = [ "${localDir}/.env.docker" ];
        volumes = [
          "${mediaDir}:/app/app/static/media"
          "${localDir}/logs:/app/logs"
          "${localDir}/tmp:/app/app/static/tmp"
        ];
        ports = [ "8030:5000" ];
        extraOptions = [ "--network=piefed_net" "--platform=linux/arm64" ];
      };

      piefed-celery = {
        image = "elestio/piefed:latest";
        dependsOn = [ "piefed-db" "piefed-redis" ];
        environmentFiles = [ "${localDir}/.env.docker" ];
        entrypoint = "./entrypoint_celery.sh";
        volumes = [
          "${mediaDir}:/app/app/static/media"
          "${localDir}/logs:/app/logs"
          "${localDir}/tmp:/app/app/static/tmp"
        ];
        extraOptions = [ "--network=piefed_net" "--platform=linux/arm64" ];
      };

      piefed-notifs = {
        image = "elestio/piefed:latest";
        dependsOn = [ "piefed-redis" ];
        environmentFiles = [ "${localDir}/.env.docker" ];
        entrypoint = "./entrypoint_async.sh";
        ports = [ "8040:8000" ];
        extraOptions = [ "--network=piefed_net" "--platform=linux/arm64" ];
      };
    };
  };

  systemd.services.init-piefed-network = {
    description = "Create Docker network for Piefed";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = "${pkgs.docker}/bin/docker network create piefed_net || true";
  };
}
