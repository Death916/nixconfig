# ~/nixconfig/nixos/configuration.nix.new
{
  config,
  pkgs,
  overlays,
  inputs,
  lib,
  ...
}:

{
  # Apply the overlays passed from the flake
  nixpkgs.overlays = [
    # overlays.rust
    # overlays.halloy
    inputs.nix-cachyos-kernel.overlays.pinned
  ];

  imports = [
    ./hardware-configuration.nix
    ../modules/nixos/laptop/desktop.nix
    ../modules/nixos/common/base.nix
    ../modules/nixos/laptop/user.nix
    ../modules/nixos/common/tailscale.nix
    ../modules/nixos/laptop/hyprland-deps.nix # New module for Hyprland dependencies
    ../modules/nixos/laptop/restic.nix
  ];

  # Use CachyOS Kernel
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest;

  # Network Optimizations (BBR + CAKE)
  boot.kernel.sysctl = {
    # Use CAKE traffic shaper to prevent lag (bufferbloat) on WiFi
    "net.core.default_qdisc" = "cake";
    # Use BBR for better throughput
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  specialisation = {
    stable-kernel.configuration = {
      system.nixos.tags = [ "stable" ];
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
      boot.kernel.sysctl = lib.mkForce {
        "net.core.default_qdisc" = "fq_codel"; # Revert to default
        "net.ipv4.tcp_congestion_control" = "cubic"; # Revert to default
      };
    };
  };

  # nix.settings.substituters = [
  # "https://hyprland.cachix.org"
  # "https://cache.flox.dev"
  # "https://nix-community.cachix.org"
  # ];
  # nix.settings.trusted-public-keys = [
  # "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
  # "flox-store-public-0:8c/B+kjIaQ+BloCmNkRUKwaVPFWkriSAd0JJvuDu4F0="
  # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  # ];




  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd start-hyprland";
        user = "death916";
      };
    };
  };

  system.stateVersion = "24.11";

  stylix.image = "/home/death916/Documents/nix-config/home-manager/wallpaper.jpg";
}