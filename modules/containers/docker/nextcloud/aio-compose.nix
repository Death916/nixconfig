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

  virtualisation.oci-containers.containers.nextcloud-aio-mastercontainer = {
    image = "nextcloud/all-in-one:latest";
    autoStart = true;
    ports = [
      "8080:8080" # AIO Interface
    ];
    environment = {
      NEXTCLOUD_DATADIR = nextcloudDataPath;
      APACHE_PORT = "11001";
      APACHE_IP_BINDING = "0.0.0.0";
      SKIP_DOMAIN_VALIDATION = "true";
    };
    volumes = [
      "nextcloud_aio_mastercontainer:/mnt/docker-aio-config"
      "/var/run/docker.sock:/var/run/docker.sock:ro"
    ];
    extraOptions = [
      "--init"
      "--sig-proxy=false"
    ];
  };

  networking.firewall.allowedTCPPorts = [
    8080
    11000
  ];
}
