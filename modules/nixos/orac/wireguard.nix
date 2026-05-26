{ config, pkgs, ... }:
{
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv4.conf.all.rp_filter" = 2;
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.200.0.1/24" ];
    listenPort = 443;
    mtu = 1280;
    privateKeyFile = "/etc/nixos/secrets/orac_private.key";

    peers = [
      {
        publicKey = "FXWrhU0t61cekY+xr31w+ETDtKSldIpVOjdywzgiIDk=";
        allowedIPs = [ "10.200.0.2/32" ];
      }
      {
        publicKey = "zqsfGglzJPY657WMRxf/S4omG7+ZkSDIpDq+ggbc9yo=";
        allowedIPs = [ "10.200.0.3/32" "10.67.3.187/32" ];
      }
    ];
  };

  networking.firewall.allowedUDPPorts = [ 443 ];
  networking.firewall.trustedInterfaces = [ "wg0" ];

  networking.firewall.extraCommands = ''
    iptables -A FORWARD -i wg0 -j ACCEPT
    iptables -t nat -A POSTROUTING -s 10.200.0.0/24 -j MASQUERADE
    iptables -t nat -A POSTROUTING -s 10.67.3.187/32 -j MASQUERADE
    iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1200
  '';
}
