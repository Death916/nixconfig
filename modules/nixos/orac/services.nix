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
      ROCKET_LOG = "critical";
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
  services.netdata = {
    enable = true;
    config.global = {
      "memory mode" = "ram";
      "debug log" = "none";
      "access log" = "none";
      "error log" = "syslog";
    };
  };
  networking.firewall.allowedTCPPorts = [ 19999 ];
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
  ];
}
