# ~/nixconfig/nextcloud-local-setup.nix
{ config, pkgs, lib, ... }:

let
  nextcloudInternalHostName = "homelab";
  # Define the paths to your externally managed password files
  adminPassFilePath = "/etc/nixos/secrets/nextcloud_admin_password";
  dbPassFilePath = "/etc/nixos/secrets/nextcloud_db_password";
  nextcloudDataPath = "/storage/nextcloud-data";
in
{
  # --- PostgreSQL Database for Nextcloud ---
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [ { name = "nextcloud"; } ];
  };

  # --- Redis for Nextcloud Caching and Locking ---
  services.redis.servers.nextcloud = {
    enable = true;
    user = "nextcloud";
    unixSocket = "/run/redis-nextcloud/redis.sock";
    port = 0;
  };
  systemd.tmpfiles.rules = [
    "d /run/redis-nextcloud 0750 nextcloud nextcloud - -"
  ];

  # --- Nextcloud Service Configuration ---
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud28; # Ensure this matches your desired Nextcloud version
    hostName = "cloud.death916.xyz"; # Use the domain handled by the reverse proxy
    https = false; # Disable HTTPS since the reverse proxy will handle it
    datadir = nextcloudDataPath;

    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      dbpassFile = dbPassFilePath;
      adminuser = "death916";
      adminpassFile = adminPassFilePath;
    };

    extraConfig = {
      "overwriteprotocol" = "https"; # Force HTTPS in Nextcloud
      "overwritehost" = "cloud.death916.xyz"; # Set the reverse proxy hostname
      "trusted_proxies" = [ "100.117.212.36" ]; # Replace with your reverse proxy's IP
      "overwrite.cli.url" = "https://cloud.death916.xyz"; # Set the base URL
    };

    settings = {
      trusted_domains = [
        "cloud.death916.xyz"
      ];
      memcache.distributed = "\\OC\\Memcache\\Redis";
      memcache.locking = "\\OC\\Memcache\\Redis";
      filelocking.enabled = true;
      redis = { host = "/run/redis-nextcloud/redis.sock"; port = 0; };
    };

    caching.redis = true; # This helps set up some Redis defaults
    phpOptions = lib.mkForce { "memory_limit" = "2G"; };
  };

  users.users.nextcloud = { isSystemUser = true; group = "nextcloud"; };
  users.groups.nextcloud = {};

  networking.firewall.allowedTCPPorts = [ 8080 ];
}

