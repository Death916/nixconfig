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

  # Port Nextcloud's internal webserver listens on (default 80 for HTTP).
  # NPM forwards to <homelab_tailscale_ip>:<internalNextcloudHttpPort>
  # Direct Tailscale clients will connect to <homelab_tailscale_ip_or_magicdns>:<internalNextcloudHttpPort>
  internalNextcloudHttpPort = 80;

  # --- For Direct Tailscale Access to homelab's Nextcloud ---
  homelabTailscaleIP = "100.65.36.116"; # REPLACE with homelab's actual Tailscale IP
  homelabMagicDNSName = "homelab"; # Or homelab.your-tailnet-name.ts.net if you use the full name
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
    package = pkgs.nextcloud31; # Verify this version

    # For the path through NPM, hostName should match the external domain.
    # For direct Tailscale access, users will use the Tailscale IP/MagicDNS name.
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

    settings = {
      # --- Trusted Domains: CRITICAL ---
      # Add all ways Nextcloud will be accessed.
      trusted_domains = [
        nextcloudExternalDomain # For access via NPM
        homelabTailscaleIP # For direct access via Tailscale IP
        homelabMagicDNSName # For direct access via Tailscale MagicDNS name
        # "localhost"                   # If you run occ commands directly on homelab
      ];

      # --- Trusted Proxies: For NPM path ---
      trusted_proxies = [ nginxProxyManagerTailscaleIP ];

      # --- Overwrite Parameters: Primarily for the NPM path ---
      # These tell Nextcloud how it looks when accessed via NPM (HTTPS, external domain).
      # When accessed directly via Tailscale IP/MagicDNS name over HTTP, these *might*
      # cause Nextcloud to generate HTTPS links, which could be an issue if you haven't
      # set up HTTPS directly on the homelab Tailscale interface.
      overwriteprotocol = "https";
      overwritehost = nextcloudExternalDomain;
      "overwrite.cli.url" = "https://${nextcloudExternalDomain}"; # For occ commands

      # If direct HTTP access over Tailscale leads to mixed content or redirect loops
      # due to the above overwrite settings, you might need `overwritecondaddr`.
      overwritecondaddr = "^${nginxProxyManagerTailscaleIP}$";
      # This would apply the overwriteprotocol/host only if request comes from NPM.
      # For simplicity, try without it first.

      # Redis and other settings
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

  # Firewall on homelab:
  # Allows NPM (and direct Tailscale clients) to connect to Nextcloud's internal HTTP port.
  # If `networking.firewall.trustedInterfaces = [ "tailscale0" ];` is in homelab.nix,
  # this is mainly for Tailscale access.
  networking.firewall.allowedTCPPorts = [ internalNextcloudHttpPort ]; # Port 80
}
