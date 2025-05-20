# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # Remove this line - overlays are now handled in flake.nix
      # ../overlays/halloy-overlay.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  powerManagement.cpuFreqGovernor = "ondemand"; # hopefully fix low cpu freq
  hardware.cpu.amd.updateMicrocode = true; # same 
  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  users.users.death916 = {
    isNormalUser = true;
    home = "/home/death916";
    description = "Death916";
    extraGroups = ["wheel" "networkmanager" ];
  };  

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };
  
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;
  #cosmic instead
  services.desktopManager.cosmic.enable = true;
  services.displayManager.cosmic-greeter.enable = true;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;
  # add flox repos
  nix.settings.trusted-substituters = [ "https://cache.flox.dev" ];
  nix.settings.trusted-public-keys = [ "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs=" ];
  # my settings
  nix.settings.experimental-features = ["nix-command" "flakes"];
  environment.systemPackages = with pkgs; [
    # Flakes clones its dependencies through the git command,
    # so git must be installed first
    git  
    vim
    wget
    tailscale
    halloy  # Add halloy to your system packages
    conda
    inputs.flox.packages.${pkgs.system}.flox

  ];
  
  # to make exit nodes work
  networking.firewall.checkReversePath = "loose";
  
  hardware.bluetooth.enable = true;
  # hardware.blueman.enable = true;
  # hardware.bluetooth.package - pkgs.bluezFull;
  
  hardware.bluetooth.powerOnBoot = true;
  # my additions
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both"; # Or "client", or "both" depending on your needs
    # Other Tailscale options...
  };
  networking.interfaces.tailscale0.mtu = 1500;
  programs.firefox.enable = true;
  
  system.stateVersion = "24.11"; # Did you read the comment?
}

