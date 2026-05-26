{ config, pkgs, ... }:

{
  networking.networkmanager.ensureProfiles.environmentFiles = [
    "/etc/nixos/secrets/wg-laptop.env"
  ];

  networking.networkmanager.ensureProfiles.profiles = {

    # PROFILE 1: laptop-work
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

    # PROFILE 2: laptop-home (Consolidated VPS Mesh)
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

    # PROFILE 3: laptop-mullvad
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
      "wireguard-peer.zqsfGglzJPY657WMRxf/S4omG7+ZkSDIpDq+ggbc9yo=" = {
        endpoint = "23.234.72.2:51820";
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
