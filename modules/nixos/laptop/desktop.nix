# ~/nixconfig/modules.new/nixos/laptop/desktop.nix
{
  config,
  pkgs,
  inputs,
  unstablePkgs,
  ...
}:

{

  hardware.rtl-sdr.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  };
  services.xserver.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.dbus.enable = true; # for nextcloud client
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;
  #cosmic instead
  # services.desktopManager.cosmic.enable = true;
  # services.displayManager.cosmic-greeter.enable = true;
  # services.desktopManager.cosmic.xwayland.enable = true;

  # This is to fix clementine gui not showing up on wayland
  environment.variables.QT_QPA_PLATFORM = "wayland";
  services.udisks2.enable = true;
  # environment.sessionVariables.NIXOS_OZONE_WL = "1"; # Required for some Electron apps

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    # portalPackage =
    #   inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  environment.systemPackages = with pkgs; [
    coreutils
    git
    vim
    wget
    tailscale
    unstablePkgs.halloy
    conda
    inputs.flox.packages.${pkgs.system}.flox
    kopia-ui
    wl-clipboard
    tail-tray
    clementine
    systemctl-tui
    btrfs-progs
    unstablePkgs.btrfs-assistant
    rust-analyzer
    snapper
    inetutils
    rustdesk
  ];

  services.snapper.configs.nix = {
    SUBVOLUME = "/nix";
    allowUsers = [ "death916" ];

    CLEANUP_EMPTY = true;
    CLEANUP_NUMBER = true;
    CLEANUP_TIMELINE = true;
    TIMELINE_CREATE = true;
    TIMELINE_LIMIT_HOURLY = 5;
    TIMELINE_LIMIT_DAILY = 7;
    TIMELINE_LIMIT_WEEKLY = 0;
    TIMELINE_LIMIT_MONTHLY = 0;
    TIMELINE_LIMIT_YEARLY = 0;
  };

  services.snapper.configs.home = {
    SUBVOLUME = "/home";
    allowUsers = [ "death916" ];

    CLEANUP_EMPTY = true;
    CLEANUP_NUMBER = true;
    CLEANUP_TIMELINE = true;
    TIMELINE_CREATE = true;
    TIMELINE_LIMIT_HOURLY = 5;
    TIMELINE_LIMIT_DAILY = 7;
    TIMELINE_LIMIT_WEEKLY = 0;
    TIMELINE_LIMIT_MONTHLY = 0;
    TIMELINE_LIMIT_YEARLY = 0;
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
