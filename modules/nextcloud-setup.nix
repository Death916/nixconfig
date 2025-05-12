# ~/nixconfig/modules/nextcloud-setup.nix
{ config, pkgs, lib, ... }:

let
  nextcloudExternalDomain = "cloud.death916.xyz";
  adminPassFilePath = "/etc/nixos/secrets/nextcloud_admin_password";
  dbPassFilePath = "/etc/nixos/secrets/nextcloud_db_password";
  nextcloudDataPath = "/storage/nextcloud-data";

  #If services.nginx is not set, Nextcloud defaults to 80 (or you specify listen port)
  internalNextcloudHttpPort = 80;
  nginxProxyManagerTailscaleIP = "100.117.212.36";
in
{
  # --- PostgreSQL Database ---
  services.postgresql = {
    enable = true; package = pkgs.postgresql_14; ensureDatabases = [ "nextcloud" ];
    ensureUsers = [ { name = "nextcloud"; } ];
  };

  # --- Redis for Caching and Locking ---
  services.redis.servers.nextcloud = {
    enable = true; 
    user = "nextcloud"; 
    unixSocket = "/run/redis-nextcloud/redis.sock";
    port = 0;
  };
  systemd.tmpfiles.rules = [ "d /run/redis-nextcloud 0750 nextcloud nextcloud - -" ];

  # --- Nextcloud Service Configuration ---
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31; # Or your preferred Nextcloud version
    hostName = nextcloudExternalDomain;
    https = false; # Let NPM Handle TLS
    configureRedis = true;
    datadir = nextcloudDataPath;
    maxUploadSize = "2G";  # Example - can be adjusted

    config = { # settings for config.php
      dbtype = "pgsql"; dbuser = "nextcloud"; dbhost = "/run/postgresql";
      dbname = "nextcloud"; dbpassFile = dbPassFilePath;
      adminuser = "death916"; adminpassFile = adminPassFilePath;
     
       
    };
      settings = {
       trusted_domains = [ nextcloudExternalDomain "100.117.212.36" "homelab" ]; 
        overwriteprotocol = "https"; # from Browser all traffic to Nextcloud will be HTTPS since Nginx terminates SSL

        overwritehost = nextcloudExternalDomain; # Tell Nextcloud what your domain is

        overwrite.cli.url = "https://${nextcloudExternalDomain}";

        trusted_proxies = [ nginxProxyManagerTailscaleIP ]; # list of IP addresses of reverse proxies that are allowed to connect to Nextcloud
        "memcache.local" = "\\OC\\Memcache\\APCu"; # See NC recommended settings
        "memcache.distributed" = "\\OC\\Memcache\\Redis"; # Distributed caching, as we also used redis
        "memcache.locking" = "\\OC\\Memcache\\Redis"; # File locking using Redis, for performance
        filelocking.enabled = true; # Finally enable file locking

      };
    phpOptions = lib.mkForce { "memory_limit" = "2G"; }; 

    
  };
  users.users.nextcloud = { isSystemUser = true; group = "nextcloud"; };
  users.groups.nextcloud = {};
}

