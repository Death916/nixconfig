# ~/nixconfig/nixos/nix-asus.nix
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
    ./hardware-nix-asus.nix
    ../modules/nixos/laptop/desktop.nix
    ../modules/nixos/common/base.nix
    ../modules/nixos/laptop/user.nix
    ../modules/nixos/common/tailscale.nix
    # ../modules/nixos/common/nebula.nix # TODO: generate nebula keys first
    ../modules/nixos/laptop/hyprland-deps.nix
    ../modules/nixos/laptop/restic.nix
    ../modules/nixos/laptop/obsidian-rclone.nix
    ../modules/nixos/laptop/wireguard.nix
  ];

  # Use linux_zen kernel for performance improvements
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  # AMD GPU display/color debug mask — required on this laptop
  boot.kernelParams = [ "amdgpu.dcdebugmask=0x600" ];

  # Network Optimizations (BBR + CAKE) for better performance
  boot.kernel.sysctl = {
    # Use CAKE traffic shaper to prevent lag (bufferbloat) on WiFi
    "net.core.default_qdisc" = "cake";
    # Use BBR for better throughput
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # TODO: generate nebula keys and certs for nix-asus before enabling
  # services.nebula.networks.deathmesh = {
  #   isLighthouse = false;
  #   lighthouses = [ "10.0.100.1" ];
  #   staticHostMap = {
  #     "10.0.100.1" = [ "10.200.0.1:4242" "lighthouse.death916.xyz:4242" ];
  #   };
  #   settings.tun.mtu = 1100;
  #   settings.lighthouse.local_allow_list.interfaces = {
  #     "laptop-work" = false;
  #     "wg.*" = false;
  #   };
  #   settings.relay.use_relays = true;
  #   settings.relay.relays = [ "10.0.100.1" ];
  #   ca = "/etc/nixos/secrets/ca.crt";
  #   cert = "/etc/nixos/secrets/laptop.crt";
  #   key = "/etc/nixos/secrets/laptop.key";
  # };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --cmd start-hyprland";
        user = "death916";
      };
    };
  };

  services.upower.enable = true;

  system.stateVersion = "24.11";

  stylix.image = "/home/death916/Documents/nix-config/home-manager/wallpaper.jpg";
}
