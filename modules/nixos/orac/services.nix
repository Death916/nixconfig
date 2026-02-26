{
  config,
  pkgs,
  lib,
  ...
}:
{

  virtualisation.docker.enable = true;

  programs.nh = {
    enable = true;
    # clean.enable = true;
    # clean.extraArgs = "--keep-since 14d --keep 3";
    flake = "/home/death916/nixconfig/";
  };

  # services.karakeep = {
  # enable = true;
  # meilisearch.enable = true;
  # browser.enable = true;
  # environmentFile = "/etc/nixos/secrets/karakeep.env";
  # extraEnvironment = {
  # PORT = "3003";
  # };
  # };

  services.vaultwarden = {
    enable = true;
    backupDir = "/var/lib/backups/vaultwarden";
    config = {
      # Refer to https://github.com/dani-garcia/vaultwarden/blob/main/.env.template
      DOMAIN = "https://vaultwarden.death916.xyz";
      SIGNUPS_ALLOWED = false;

      ROCKET_ADDRESS = "100.72.187.12";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "warn";
      environmentFile = "/var/lib/vaultwarden/vault.env";
      # This example assumes a mailserver running on localhost,
      # thus without transport encryption.
      # If you use an external mail server, follow:
      #   https://github.com/dani-garcia/vaultwarden/wiki/SMTP-configuration
      # SMTP_HOST = "127.0.0.1";
      # SMTP_PORT = 25;
      # SMTP_SSL = false;

      # SMTP_FROM = "admin@bitwarden.example.com";
      # SMTP_FROM_NAME = "example.com Bitwarden server";
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

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "forgejo" ];
    ensureUsers = [
      {
        name = "forgejo";
        ensureDBOwnership = true;
      }
    ];
  };

  services.adguardhome = {
    enable = true;
    openFirewall = true;
    mutableSettings = true;
    settings = {
      http = {
        address = "127.0.0.1:3000";
      };
      dns = {
        # bind_hosts = [
        # "192.168.0.116"
        "100.72.187.12"
        # ];
        port = 53;
        upstream_dns = [
          "9.9.9.9"
          "8.8.8.8"
        ];
        bootstrap_dns = [
          "9.9.9.9"
          "8.8.4.4"
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;
        parental_enabled = false;
        safe_search = {
          enabled = false;
        };
      };
      filters =
        lib.map
          (url: {
            enabled = true;
            url = url;
          })
          [
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"
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
