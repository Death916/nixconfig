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

  # --- Bootloader: systemd-boot ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # --- System Optimizations ---
  hardware.enableRedistributableFirmware = true;
  services.btrfs.autoScrub.enable = true;

  # --- BTRFS Dynamic Swapfile (16GB) ---
  swapDevices = lib.mkForce [ ]; # Disable standard swap from base.nix
  services.btrfs.swapfile.enable = true;
  services.btrfs.swapfile.size = "16G";

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
