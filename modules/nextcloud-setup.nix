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
    package = pkgs.nextcloud31;
    hostName = nextcloudInternalHostName;
    https = false;
   # port = 8080;
    datadir = nextcloudDataPath;
    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      dbpassFile = dbPassFilePath; # Points to your external file
      #dataDir = nextcloudDataPath;  # Points to your external data directory
      adminuser = "ncadmin";
      adminpassFile = adminPassFilePath; # Points to your external file

     # overwriteprotocol = "http";
    };

    caching.redis = true;
    extraOptions = {
      memcache.distributed = "\\OC\\Memcache\\Redis";
      memcache.locking = "\\OC\\Memcache\\Redis";
      filelocking.enabled = true;
      redis = { host = "/run/redis-nextcloud/redis.sock"; port = 0; };
    };
    phpOptions = { "memory_limit" = "1G"; };
    user = "nextcloud";
   
  };

  users.users.nextcloud = { isSystemUser = true; group = "nextcloud"; };
  users.groups.nextcloud = {};

  networking.firewall.allowedTCPPorts = [ 8080 ];
}

