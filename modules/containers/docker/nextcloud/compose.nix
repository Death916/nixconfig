{
  config,
  pkgs,
  lib,
  ...
}:

let
  nextcloudExternalDomain = "cloud.death916.xyz";
  collaboraExternalDomain = "office.death916.xyz";

  nextcloudDataPath = "/storage/nextcloud-data";
  adminPassFilePath = "/etc/nixos/secrets/nextcloud_admin_password";
  dbPassFilePath = "/etc/nixos/secrets/nextcloud_db_password";

  nginxProxyManagerTailscaleIP = "100.117.212.36";
  homelabTailscaleIP = "100.65.36.116";

  dockerBaseDir = "/var/lib/nextcloud-docker";
in
{
  virtualisation.oci-containers.backend = "docker";

  systemd.services.init-nextcloud-network = {
    description = "Create network for Nextcloud containers";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      ${pkgs.docker}/bin/docker network create nextcloud-net || true
    '';
  };

  virtualisation.oci-containers.containers = {

    nextcloud-db = {
      image = "postgres:14-alpine";
      autoStart = true;
      environment = {
        POSTGRES_DB = "nextcloud";
        POSTGRES_USER = "nextcloud";
        POSTGRES_PASSWORD_FILE = "/run/secrets/db_pass";
      };
      volumes = [
        "${dockerBaseDir}/db:/var/lib/postgresql/data"
        "${dbPassFilePath}:/run/secrets/db_pass:ro"
      ];
      extraOptions = [
        "--network=nextcloud-net"
        "--network-alias=db"
      ];
    };

    nextcloud-redis = {
      image = "redis:alpine";
      autoStart = true;
      extraOptions = [
        "--network=nextcloud-net"
        "--network-alias=redis"
      ];
    };

    nextcloud-app = {
      image = "nextcloud:32";
      autoStart = true;
      environment = {
        POSTGRES_HOST = "db";
        POSTGRES_DB = "nextcloud";
        POSTGRES_USER = "nextcloud";
        POSTGRES_PASSWORD_FILE = "/run/secrets/db_pass";

        REDIS_HOST = "redis";

        NEXTCLOUD_ADMIN_USER = "death916";
        NEXTCLOUD_ADMIN_PASSWORD_FILE = "/run/secrets/admin_pass";

        NEXTCLOUD_TRUSTED_DOMAINS = "${nextcloudExternalDomain} ${homelabTailscaleIP} homelab";
        OVERWRITEPROTOCOL = "https";
        OVERWRITEHOST = nextcloudExternalDomain;
        OVERWRITECLIURL = "https://${nextcloudExternalDomain}";

        PHP_MEMORY_LIMIT = "4G";
        PHP_UPLOAD_LIMIT = "4G";
      };
      volumes = [
        "${nextcloudDataPath}/data:/var/www/html/data"
        "${dockerBaseDir}/html:/var/www/html"
        "${dbPassFilePath}:/run/secrets/db_pass:ro"
        "${adminPassFilePath}:/run/secrets/admin_pass:ro"
      ];
      ports = [ "8080:80" ];
      dependsOn = [
        "nextcloud-db"
        "nextcloud-redis"
      ];
      extraOptions = [ "--network=nextcloud-net" ];
    };

    nextcloud-collabora = {
      image = "collabora/code";
      autoStart = true;
      environment = {
        domain = collaboraExternalDomain;
        aliasgroup1 = "https://cloud\\.death916\\.xyz:443";
        extra_params = "--o:ssl.enable=false --o:ssl.termination=true --o:admin_console.username=admin";
        wopi_allowlist = "127.0.0.1,0.0.0.0,::1,${nginxProxyManagerTailscaleIP}";
        username = "admin";
        password_file = "/run/secrets/admin_pass";
      };
      volumes = [
        "${adminPassFilePath}:/run/secrets/admin_pass:ro"
      ];
      ports = [ "9980:9980" ];
      extraOptions = [
        "--network=nextcloud-net"
        "--network-alias=collabora"
        "--cap-add=MKNOD"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [
    8080
    9980
  ];
}
