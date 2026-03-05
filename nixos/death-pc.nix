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
    ../modules/nixos/laptop/hyprland-deps.nix
    ../modules/nixos/desktop/gaming.nix
  ];

  networking.hostName = "death-pc";

  # Use linux_zen kernel for performance improvements
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # --- Bootloader: GRUB Dual-Boot ---
  # Overriding the systemd-boot from base.nix
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true; # Automatically detects Windows on the Small SSD
    default = 0;
  };
  boot.loader.efi.canTouchEfiVariables = true;

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
