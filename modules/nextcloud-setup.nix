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
    package = pkgs.nextcloud28; # Changed back to 28 for consistency, verify your actual package
    hostName = "cloud.death916.xyz"; # This will be automatically added to trusted_domains by the module
    https = false; 
    datadir = nextcloudDataPath;

    config = { # For direct config.php entries
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      dbpassFile = dbPassFilePath;
      adminuser = "death916"; # Changed from ncadmin as per your file
      adminpassFile = adminPassFilePath;
      # 'overwriteprotocol' is a direct config.php key, so it belongs here for reverse proxy setups
      overwriteprotocol = "https"; 
      # 'overwritehost' and 'overwrite.cli.url' would also go here if needed for reverse proxy
     # overwritehost = "cloud.death916.xyz";
     # "overwrite.cli.url" = "https://cloud.death916.xyz";
      # 'trusted_proxies' would also go here for reverse proxy setup
      trusted_proxies = [ "YOUR_REVERSE_PROXY_IP" ]; # e.g., "127.0.0.1" if on same machine
    };

    # 'trusted_domains' goes under 'settings'
    settings = {
      trusted_domains = [ 
        "cloud.death916.xyz" 
        # The module usually adds config.services.nextcloud.hostName and localhost automatically.
        # If you want to be explicit and override:
        # lib.mkForce [ "localhost" config.services.nextcloud.hostName "cloud.death916.xyz" ]
      ];
      # Your Redis settings from before:
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

