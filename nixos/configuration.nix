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
  ];

  imports = [
    ./hardware-configuration.nix
    ../modules/nixos/laptop/desktop.nix
    ../modules/nixos/common/base.nix
    ../modules/nixos/laptop/user.nix
    # ../modules/nixos/common/tailscale.nix
    ../modules/nixos/common/nebula.nix
    ../modules/nixos/laptop/hyprland-deps.nix # New module for Hyprland dependencies
    ../modules/nixos/laptop/restic.nix
    ../modules/nixos/laptop/obsidian-rclone.nix
    ../modules/nixos/laptop/wireguard.nix
  ];

  # Use linux_zen kernel for performance improvements
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # Network Optimizations (BBR + CAKE) for better performance
  boot.kernel.sysctl = {
    # Use CAKE traffic shaper to prevent lag (bufferbloat) on WiFi
    "net.core.default_qdisc" = "cake";
    # Use BBR for better throughput
    "net.ipv4.tcp_congestion_control" = "bbr";
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

  services.nebula.networks.deathmesh = {
    isLighthouse = false;
    lighthouses = [ "10.0.100.1" ];
    staticHostMap = {
      "10.0.100.1" = [ "10.200.0.1:4242" "lighthouse.death916.xyz:4242" ];
    };
    settings.tun.mtu = 1100;
    settings.lighthouse.local_allow_list.interfaces = {
      "laptop-work" = false;
      "wg.*" = false;
    };
    settings.relay.use_relays = true;
    settings.relay.relays = [ "10.0.100.1" ];
    ca = "/etc/nixos/secrets/ca.crt";
    cert = "/etc/nixos/secrets/laptop.crt";
    key = "/etc/nixos/secrets/laptop.key";
  };

  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "start-hyprland";
        user = "death916";
      };
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd start-hyprland";
        user = "death916";
      };
    };
  };

  security.pam.services.hyprlock = {
    text = ''
      auth     sufficient     pam_permit.so
      account  include        login
      password include        login
      session  include        login
    '';
  };

  services.upower.enable = true;

  system.stateVersion = "24.11";

  stylix.image = "/home/death916/Documents/nix-config/home-manager/wallpaper.jpg";
}
