{ config, pkgs, ... }: {
  networking.networkmanager.ensureProfiles.environmentFiles = [ "/etc/nixos/secrets/wg-desktop.env" ];
  networking.networkmanager.ensureProfiles.profiles.desktop-work = {
    connection = {
      id = "desktop-work";
      type = "wireguard";
      interface-name = "desktop-work";
      mtu = 1280;
    };
    wireguard.private-key = "$WG_PRIVATE_KEY";
    "wireguard-peer.VbKDcgXQAF5TSAjifWVd9RXJNVfmzpIW5q/wNPxcNDw=" = {
      endpoint = "lighthouse.death916.xyz:443";
      allowed-ips = "0.0.0.0/0";
      persistent-keepalive = 25;
    };
    ipv4 = {
      method = "manual";
      addresses = "10.200.0.4/24";
      dns = "10.200.0.1;10.0.100.1;10.0.100.2;9.9.9.9;";
      dns-priority = -50;
    };
    ipv6.method = "disabled";
  };
}
