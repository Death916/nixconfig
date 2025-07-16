# ~/nixconfig/modules.new/nixos/laptop/desktop.nix
{
  config,
  pkgs,
  inputs,
  unstablePkgs,
  ...
}:

{
  services.xserver.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.dbus.enable = true; # for nextcloud client
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;
  #cosmic instead
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.xwayland.enable = true;

  # This is to fix clementine gui not showing up on wayland
  environment.variables.QT_QPA_PLATFORM = "wayland";

  nix.settings.trusted-substituters = [ "https://cache.flox.dev" ];
  nix.settings.trusted-public-keys = [
    "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
  ];

  environment.systemPackages = with pkgs; [
    coreutils
    git
    vim
    wget
    tailscale
    halloy # Add halloy to your system packages
    conda
    inputs.flox.packages.${pkgs.system}.flox
    kopia-ui
    stremio
    wl-clipboard
    tail-tray
    clementine
    systemctl-tui
    btrfs-progs
    unstablePkgs.btrfs-assistant
    rust-analyzer
    snapper
  ];

  services.snapper.configs.nix = {
    subvolume = "/nix";
    extraConfig = ''
      ALLOW_USERS="death916"
      TIMELINE_CREATE="yes"
      TIMELINE_LIMIT_HOURLY="5"
      TIMELINE_LIMIT_DAILY="7"
      TIMELINE_LIMIT_WEEKLY="0"
      TIMELINE_LIMIT_MONTHLY="0"
      TIMELINE_LIMIT_YEARLY="0"
      # Cleanup algorithms
      CLEANUP_TIMELINE="yes"
      CLEANUP_NUMBER="yes"
      CLEANUP_EMPTY="yes"
    '';
  };

  services.snapper.configs.home = {
    subvolume = "/home";
    extraConfig = ''
      ALLOW_USERS="death916"
      TIMELINE_CREATE="yes"
      TIMELINE_LIMIT_HOURLY="5"
      TIMELINE_LIMIT_DAILY="7"
      TIMELINE_LIMIT_WEEKLY="0"
      TIMELINE_LIMIT_MONTHLY="0"
      TIMELINE_LIMIT_YEARLY="0"
      # Cleanup algorithms
      CLEANUP_TIMELINE="yes"
      CLEANUP_NUMBER="yes"
      CLEANUP_EMPTY="yes"
    '';
  };

  virtualisation.docker.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  programs.firefox.enable = true;
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 10";
    flake = "/home/death916/Documents/nix-config/";
  };
  services.fprintd.enable = false;
}
