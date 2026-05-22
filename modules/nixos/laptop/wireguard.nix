{ config, pkgs, ... }:

{
  networking.networkmanager.ensureProfiles.environmentFiles = [
    "/etc/nixos/secrets/wg-laptop.env"
  ];

  networking.networkmanager.ensureProfiles.profiles = {

    # PROFILE 1: laptop-work (Full Tunnel for Coffee Shops / Work)
    laptop-work = {
      connection = {
        id = "laptop-work";
        type = "wireguard";
        interface-name = "laptop-work";
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

    # PROFILE 2: laptop-home (Split Tunnel - Only for DNS and VPN-specific IPs)
    laptop-home = {
      connection = {
        id = "laptop-home";
        type = "wireguard";
        interface-name = "laptop-home";
        mtu = 1280;
      };
      wireguard = {
        private-key = "$WG_PRIVATE_KEY";
      };
      "wireguard-peer.VbKDcgXQAF5TSAjifWVd9RXJNVfmzpIW5q/wNPxcNDw=" = {
        endpoint = "lighthouse.death916.xyz:443";
        # Only route VPN subnet traffic. Nebula (10.0.100.x) is explicitly ignored
        # so it stays natively on dmesh0.
        allowed-ips = "10.200.0.0/24";
        persistent-keepalive = 25;
      };
      ipv4 = {
        method = "manual";
        addresses = "10.200.0.2/24";
        # Force DNS to your Homelab AdGuard, with VPS AdGuard as fallback
        dns = "10.0.100.2;10.0.100.1;";
        dns-search = "death;";
        dns-priority = -50;
      };
      ipv6 = {
        method = "disabled";
      };
    };

  };
}
