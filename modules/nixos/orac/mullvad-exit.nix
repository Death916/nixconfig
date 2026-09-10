{ config, pkgs, lib, ... }:
{
  systemd.tmpfiles.rules = [
    "d /var/lib/containers/mullvad-exit/tailscale 0700 root root -"
    "f /etc/nixos/secrets/wg-mullvad.key 0600 root root -"
  ];

  containers.mullvad-exit = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.1";
    localAddress = "192.168.100.2";
    enableTun = true;

    bindMounts = {
      "/etc/wireguard/wg-mullvad.key" = {
        hostPath = "/etc/nixos/secrets/wg-mullvad.key";
        isReadOnly = true;
      };
      "/var/lib/tailscale" = {
        hostPath = "/var/lib/containers/mullvad-exit/tailscale";
        isReadOnly = false;
      };
    };

    config = { pkgs, ... }: {
      networking.firewall.checkReversePath = "loose";
      networking.firewall.trustedInterfaces = [ "tailscale0" ];

      networking.firewall.extraCommands = ''
        iptables -t nat -A POSTROUTING -o wg-mullvad -j MASQUERADE
      '';

      networking.wg-quick.interfaces.wg-mullvad = {
        address = [ "10.69.143.223/32" ];
        dns = [ "100.64.0.3" ];
        privateKeyFile = "/etc/wireguard/wg-mullvad.key";
        peers = [
          {
            publicKey = "zqsfGglzJPY657WMRxf/S4omG7+ZkSDIpDq+ggbc9yo=";
            endpoint = "23.234.72.2:51820";
            allowedIPs = [ "0.0.0.0/0" ];
            persistentKeepalive = 25;
          }
        ];
      };

      services.tailscale = {
        enable = true;
        useRoutingFeatures = "both";
        extraSetFlags = [
          "--advertise-exit-node"
          "--accept-dns=false"
        ];
      };

      environment.systemPackages = with pkgs; [
        iptables
        iproute2
        curl
      ];
    };
  };

  networking.firewall.extraCommands = lib.mkAfter ''
    iptables -t nat -A POSTROUTING -s 192.168.100.0/24 -j MASQUERADE
    iptables -A FORWARD -i ve-mullvad-exit -j ACCEPT
    iptables -A FORWARD -o ve-mullvad-exit -j ACCEPT
  '';
}
