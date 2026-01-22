# ~/nixconfig/modules/nextcloud-setup.nix
{
  config,
  pkgs,
  lib,
  ...
}:

let
  nextcloudExternalDomain = "cloud.death916.xyz"; # Domain used by NPM
  adminPassFilePath = "/etc/nixos/secrets/nextcloud_admin_password";
  dbPassFilePath = "/etc/nixos/secrets/nextcloud_db_password";
  nextcloudDataPath = "/storage/nextcloud-data";
  nginxProxyManagerTailscaleIP = "100.117.212.36"; # IP of your NPM

  internalNextcloudHttpPort = 80;

  # --- For Direct Tailscale Access to homelab's Nextcloud ---
  homelabTailscaleIP = "100.65.36.116";
  homelabMagicDNSName = "homelab";
in
{
  # --- PostgreSQL & Redis setup ... (as before) ---
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_14;
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [ { name = "nextcloud"; } ];
  };
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
    package = pkgs.nextcloud32;

    hostName = nextcloudExternalDomain;

    https = false; # NPM handles HTTPS. Nextcloud serves HTTP internally.
    datadir = nextcloudDataPath;
    maxUploadSize = "2G";

    config = {
      dbtype = "pgsql";
      dbuser = "nextcloud";
      dbhost = "/run/postgresql";
      dbname = "nextcloud";
      dbpassFile = dbPassFilePath;
      adminuser = "death916";
      adminpassFile = adminPassFilePath;
    };
    extraOptions = {
      session_keepalive = true;
      remember_login_cookie_lifetime = 7776000; # 90 days in seconds
    };

    settings = {
      trusted_domains = [
        nextcloudExternalDomain # For access via NPM
        homelabTailscaleIP # For direct access via Tailscale IP
        homelabMagicDNSName # For direct access via Tailscale MagicDNS name
        # "localhost"                   # If you run occ commands directly on homelab
      ];

      # --- Trusted Proxies: For NPM path ---
      trusted_proxies = [ nginxProxyManagerTailscaleIP ];

      overwriteprotocol = "https";
      overwritehost = nextcloudExternalDomain;
      "overwrite.cli.url" = "https://${nextcloudExternalDomain}"; # For occ commands

      overwritecondaddr = "^${nginxProxyManagerTailscaleIP}$";
      "memcache.local" = "\\OC\\Memcache\\APCu";
      "memcache.distributed" = "\\OC\\Memcache\\Redis";
      "memcache.locking" = "\\OC\\Memcache\\Redis";
      filelocking.enabled = true;
      redis = {
        host = "/run/redis-nextcloud/redis.sock";
        port = 0;
      };
    };
    caching.redis = true;
    phpOptions = lib.mkForce { "memory_limit" = "4G"; };
  };

  users.users.nextcloud = {
    isSystemUser = true;
    group = "nextcloud";
  };
  users.groups.nextcloud = { };

  networking.firewall.allowedTCPPorts = [ internalNextcloudHttpPort ]; # Port 80
}
