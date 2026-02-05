{
  config,
  pkgs,
  lib,
  ...
}:

let
  # --- Configuration Variables ---
  nextcloudExternalDomain = "cloud.death916.xyz";
  collaboraExternalDomain = "office.death916.xyz"; # New: Domain for Collabora

  adminPassFilePath = "/etc/nixos/secrets/nextcloud_admin_password";
  dbPassFilePath = "/etc/nixos/secrets/nextcloud_db_password";
  nextcloudDataPath = "/storage/nextcloud-data";

  # Network / Proxy
  nginxProxyManagerTailscaleIP = "100.117.212.36";
  homelabTailscaleIP = "100.65.36.116";
  homelabMagicDNSName = "homelab";

  internalNextcloudHttpPort = 80;
  collaboraPort = 9980;
in
{
  # --- Database & Cache ---
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

  # --- Nextcloud ---
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    hostName = nextcloudExternalDomain;
    https = false; # Handled by NPM
    datadir = nextcloudDataPath;
    maxUploadSize = "2G";

    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) richdocuments;
    };

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
      remember_login_cookie_lifetime = 7776000;
    };
    settings.enabledPreviewProviders = [
      "OC\\Preview\\BMP"
      "OC\\Preview\\GIF"
      "OC\\Preview\\JPEG"
      "OC\\Preview\\Krita"
      "OC\\Preview\\MarkDown"
      "OC\\Preview\\MP3"
      "OC\\Preview\\OpenDocument"
      "OC\\Preview\\PNG"
      "OC\\Preview\\TXT"
      "OC\\Preview\\XBitmap"
      "OC\\Preview\\Movie"
      "OC\\Preview\\MSOffice2003"
      "OC\\Preview\\MSOffice2007"
      "OC\\Preview\\MSOfficeDoc"
      "OC\\Preview\\PDF"
      "OC\\Preview\\Photoshop"
      "OC\\Preview\\SVG"
      "OC\\Preview\\YML"
    ];
    settings = {
      trusted_domains = [
        nextcloudExternalDomain
        homelabTailscaleIP
        homelabMagicDNSName
      ];
      trusted_proxies = [ nginxProxyManagerTailscaleIP ];

      overwriteprotocol = "https";
      overwritehost = nextcloudExternalDomain;
      "overwrite.cli.url" = "https://${nextcloudExternalDomain}";
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

  # --- Collabora Online (Added) ---
  services.collabora-online = {
    enable = true;
    port = collaboraPort;
    settings = {
      ssl = {
        enable = false;
        termination = true;
      };
      server_name = collaboraExternalDomain;

      # Listening on any interface so your external NPM can reach it via Tailscale IP
      net = {
        listen = "any";
        post_allow.host = [
          "0.0.0.0"
          "::1"
          "127.0.0.1"
          nginxProxyManagerTailscaleIP
        ];
      };

      storage.wopi = {
        "@allow" = true;
        host = [ nextcloudExternalDomain ];
      };
    };
  };

  # --- Auto-configure Nextcloud to use Collabora ---
  systemd.services.nextcloud-config-collabora =
    let
      inherit (config.services.nextcloud) occ;
      wopi_url = "http://127.0.0.1:${toString collaboraPort}";
      public_wopi_url = "https://${collaboraExternalDomain}";
      wopi_allowlist = lib.concatStringsSep "," [
        "0.0.0.0"
        "127.0.0.1"
        "::1"
        nginxProxyManagerTailscaleIP
      ];
    in
    {
      wantedBy = [ "multi-user.target" ];
      after = [
        "nextcloud-setup.service"
        "coolwsd.service"
      ];
      requires = [ "coolwsd.service" ];
      script = ''
        ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_url --value ${lib.escapeShellArg wopi_url}
        ${occ}/bin/nextcloud-occ config:app:set richdocuments public_wopi_url --value ${lib.escapeShellArg public_wopi_url}
        ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_allowlist --value ${lib.escapeShellArg wopi_allowlist}
        ${occ}/bin/nextcloud-occ richdocuments:setup
      '';
      serviceConfig = {
        Type = "oneshot";
        # User = "nextcloud";
      };
    };

  # --- System & Networking ---
  systemd.tmpfiles.rules = [ "d /run/redis-nextcloud 0750 nextcloud nextcloud - -" ];

  users.users.nextcloud = {
    isSystemUser = true;
    group = "nextcloud";
  };
  users.groups.nextcloud = { };

  networking.firewall.allowedTCPPorts = [
    internalNextcloudHttpPort
    collaboraPort
  ];
}
