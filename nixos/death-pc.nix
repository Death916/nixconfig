{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-death-pc.nix
    ../modules/nixos/desktop/desktop.nix
    ../modules/nixos/common/base.nix
    ../modules/nixos/laptop/user.nix
    ../modules/nixos/common/tailscale.nix
    ../modules/nixos/common/nebula.nix
    ../modules/nixos/laptop/hyprland-deps.nix
    ../modules/nixos/desktop/gaming.nix
  ];

  services.nebula.networks.deathmesh = {
    isLighthouse = false;
    lighthouses = [ "10.0.100.1" ];
    staticHostMap = {
      "10.0.100.1" = [ "lighthouse.death916.xyz:4242" ];
    };
    ca = "/etc/nixos/secrets/ca.crt";
    cert = "/etc/nixos/secrets/desktop.crt";
    key = "/etc/nixos/secrets/desktop.key";
  };

  networking.hostName = "death-pc";

  # Use linux_zen kernel for performance improvements
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  boot.kernelParams = [ 
    "nvidia-drm.modeset=1" 
    "nvidia_drm.fbdev=1" 
  ];

  # Fix for resume lockups on Systemd 256+ (Common in 2025/2026)
  systemd.services.systemd-suspend.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
  systemd.services.systemd-hibernate.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";
  systemd.services.systemd-hybrid-sleep.environment.SYSTEMD_SLEEP_FREEZE_USER_SESSIONS = "false";

  # --- Bootloader: systemd-boot ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # --- System Optimizations ---
  hardware.enableRedistributableFirmware = true;
  services.btrfs.autoScrub.enable = true;

  # --- NVIDIA G-SYNC / Tear-Free ---
  services.xserver.screenSection = ''
    Option "AllowGNULL" "False"
    Option "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On, AllowGSYNC=On}"
  '';

  # State version for this specific machine
  system.stateVersion = "25.11";

  # Set wallpaper for Stylix
  stylix.image = "/home/death916/Documents/nix-config/home-manager/wallpaper.jpg";
}
