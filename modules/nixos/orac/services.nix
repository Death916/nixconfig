{
  config,
  pkgs,
  lib,
  ...
}:
{

  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      immich-machine-learning = {
        image = "ghcr.io/immich-app/immich-machine-learning:release";
        ports = [ "3004:3003" ];
        volumes = [ "immich-ml-cache:/cache" ];
      };
    };
  };

  programs.nh = {
    enable = true;
    flake = "/home/death916/nixconfig/";
  };

  services.vaultwarden = {
    enable = true;
    backupDir = "/var/lib/backups/vaultwarden";
    config = {
      DOMAIN = "https://vaultwarden.death916.xyz";
      SIGNUPS_ALLOWED = false;
      ROCKET_ADDRESS = "100.72.187.12";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "warn";
      environmentFile = "/var/lib/vaultwarden/vault.env";
    };
  };

  services.miniflux = {
    enable = true;
    adminCredentialsFile = "/etc/nixos/secrets/minifluxadmin";
    config = {
      LISTEN_ADDR = "0.0.0.0:8086";
      POLLING_FREQUENCY = 15;
    };
  };

  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "http://orac:2586";
      listen-http = "0.0.0.0:2586";
      behind-proxy = false;
      auth-default-access = "deny-all";
      enable-login = true;
    };
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "forgejo" "umami" ];
    ensureUsers = [
      {
        name = "forgejo";
        ensureDBOwnership = true;
      }
      {
        name = "umami";
        ensureDBOwnership = true;
      }
    ];
  };

  services.adguardhome = {
    enable = true;
    openFirewall = true;
    mutableSettings = false;
    settings = {
      http = {
        address = "127.0.0.1:3000";
      };
      dns = {
        bind_hosts = [ "0.0.0.0" ];
        port = 53;
        upstream_dns = [
          "9.9.9.9"
          "8.8.8.8"
        ];
        bootstrap_dns = [
          "9.9.9.9"
          "8.8.4.4"
        ];
        rewrites = [
          { domain = "orac.death"; answer = "10.0.100.1"; enabled = true; }
          { domain = "homelab.death"; answer = "10.0.100.2"; enabled = true; }
          { domain = "desktop.death"; answer = "10.0.100.3"; enabled = true; }
          { domain = "laptop.death"; answer = "10.0.100.4"; enabled = true; }
          { domain = "orac"; answer = "10.0.100.1"; enabled = true; }
          { domain = "homelab"; answer = "10.0.100.2"; enabled = true; }
          { domain = "desktop"; answer = "10.0.100.3"; enabled = true; }
          { domain = "laptop"; answer = "10.0.100.4"; enabled = true; }
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        parental_enabled = false;
        safe_search = {
          enabled = false;
        };
        rewrites = [
          { domain = "orac.death"; answer = "10.0.100.1"; enabled = true; }
          { domain = "homelab.death"; answer = "10.0.100.2"; enabled = true; }
          { domain = "desktop.death"; answer = "10.0.100.3"; enabled = true; }
          { domain = "laptop.death"; answer = "10.0.100.4"; enabled = true; }
          { domain = "orac"; answer = "10.0.100.1"; enabled = true; }
          { domain = "homelab"; answer = "10.0.100.2"; enabled = true; }
          { domain = "desktop"; answer = "10.0.100.3"; enabled = true; }
          { domain = "laptop"; answer = "10.0.100.4"; enabled = true; }
        ];
      };
      clients = {
        persistent = [
          {
            name = "Laptop";
            ids = [ "10.200.0.2" "10.0.100.4" ];
            use_global_settings = true;
            filtering_enabled = true;
            parental_enabled = false;
            safesearch_enabled = false;
          }
          {
            name = "Android-Phone";
            ids = [ "10.200.0.3" ];
            use_global_settings = true;
            filtering_enabled = true;
            parental_enabled = false;
            safesearch_enabled = false;
          }
          {
            name = "Homelab";
            ids = [ "10.0.100.2" ];
            use_global_settings = true;
            filtering_enabled = true;
            parental_enabled = false;
            safesearch_enabled = false;
          }
          {
            name = "Desktop";
            ids = [ "10.0.100.3" "10.200.0.4" ];
            use_global_settings = true;
            filtering_enabled = true;
            parental_enabled = false;
            safesearch_enabled = false;
          }
        ];
      };
      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt";
          name = "AdGuard Base filter";
          id = 1;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt";
          name = "Malicious URL Blocklist";
          id = 2;
        }
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 3;
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    tailscale
    rsync
    multipath-tools
    btop
    wget
    unzip
    manix
    pipes-rs
    fzf
  ];
}
