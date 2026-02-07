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
      "8080:8080"   # AIO Interface
      "11000:11000" # Apache Port (for Reverse Proxy)
    ];
    environment = {
      NEXTCLOUD_DATADIR = nextcloudDataPath;
      APACHE_PORT = "11000";
      APACHE_IP_BINDING = "0.0.0.0";
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
