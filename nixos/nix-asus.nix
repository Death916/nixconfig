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
    ../modules/nixos/common/nebula.nix
    ../modules/nixos/laptop/hyprland-deps.nix
    ../modules/nixos/laptop/restic.nix
    ../modules/nixos/laptop/obsidian-rclone.nix
    ./acpi-override.nix
  ];

  # Use linux_zen kernel for performance improvements
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;
  networking.hostName = "nix-asus";
  # AMD GPU display/color debug mask — required on this laptop
  boot.kernelParams = [ "amdgpu.dcdebugmask=0x600" ];

  # Network Optimizations (BBR + CAKE) for better performance
  boot.kernel.sysctl = {
    # Use CAKE traffic shaper to prevent lag (bufferbloat) on WiFi
    "net.core.default_qdisc" = "cake";
    # Use BBR for better throughput
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

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
    cert = "/etc/nixos/secrets/nix-asus.crt";
    key = "/etc/nixos/secrets/nix-asus.key";
  };

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

  # Enable proprietary firmware/microcode (essential for AMD sound chips)
  hardware.enableRedistributableFirmware = true;

  # Enable RealtimeKit for PipeWire audio scheduling
  security.rtkit.enable = true;

  system.stateVersion = "24.11";

  stylix.image = "/home/death916/Downloads/wp14437838-4k-oled-space-wallpapers.jpg";

  # Custom Wireguard NetworkManager profiles for this laptop only
  networking.networkmanager.ensureProfiles.environmentFiles = [
    "/etc/nixos/secrets/wg-laptop.env"
  ];

  networking.networkmanager.ensureProfiles.profiles = {
    laptop-work = {
      connection = {
        id = "laptop-work";
        type = "wireguard";
        interface-name = "laptop-work";
        autoconnect = "false";
        mtu = 1280;
      };
      wireguard = {
        private-key = "$WG_PRIVATE_KEY";
      };
      "wireguard-peer.VbKDcgXQAF5TSAjifWVd9RXJNVfmzpIW5q/wNPxcNDw=" = {
        endpoint = "lighthouse.death916.xyz:443";
        allowed-ips = "0.0.0.0/0";
        persistent-keepalive = 25;
      };
      ipv4 = {
        method = "manual";
        addresses = "10.200.0.2/24";
        dns = "10.200.0.1;10.0.100.1;10.0.100.2;9.9.9.9;";
        dns-priority = -50;
        routes = "$VPS_PUBLIC_IP/32 0.0.0.0 0";
        routing-rule1 = "priority 2500 to 10.0.100.0/24 table 254";
      };
      ipv6 = {
        method = "disabled";
      };
    };

    laptop-home = {
      connection = {
        id = "laptop-home";
        type = "wireguard";
        interface-name = "laptop-home";
        autoconnect = "true";
        mtu = 1280;
      };
      wireguard = {
        private-key = "$WG_PRIVATE_KEY";
      };
      "wireguard-peer.VbKDcgXQAF5TSAjifWVd9RXJNVfmzpIW5q/wNPxcNDw=" = {
        endpoint = "lighthouse.death916.xyz:443";
        allowed-ips = "10.200.0.0/24";
        persistent-keepalive = 25;
      };
      ipv4 = {
        method = "manual";
        addresses = "10.200.0.2/24";
        dns = "10.0.100.2;10.0.100.1;";
        dns-search = "death;~.;";
        dns-priority = -50;
      };
      ipv6 = {
        method = "disabled";
      };
    };

    laptop-mullvad = {
      connection = {
        id = "laptop-mullvad";
        type = "wireguard";
        interface-name = "wg-mullvad";
        autoconnect = "true";
      };
      wireguard = {
        private-key = "$MULLVAD_PRIVATE_KEY";
      };
      "wireguard-peer.kZkubkNYgzXKAWuF70RA/XGhOxorA4C3Ph3v4t+LThM=" = {
        endpoint = "23.234.73.2:51820";
        allowed-ips = "0.0.0.0/0";
      };
      ipv4 = {
        method = "manual";
        addresses = "$MULLVAD_CLIENT_IP/32";
        dns = "10.64.0.1;";
        dns-priority = 100;
      };
      ipv6 = {
        method = "disabled";
      };
    };
  };
}
