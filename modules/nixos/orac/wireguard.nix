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
        publicKey = "X9QyXN5/AB7Lx1xXEHCyfwG9lHSPPV0QNtasrmfgYGQ=";
        allowedIPs = [ "10.200.0.2/32" ];
      }
      {
        publicKey = "YXo02jorch0ihTErqCJeaiKldfWzftqteQJxdQJRJB4=";
        allowedIPs = [ "10.200.0.3/32" "10.67.3.187/32" ];
      }
    ];
  };

  # Mullvad leg for the laptop chain: laptop -> wg0 (443) -> wg-mullvad -> Mullvad
  # Routes land in table 100 only, so orac's own traffic stays on the direct uplink.
  # Reuses the laptop's existing Mullvad key (only client of this tunnel).
  networking.wireguard.interfaces."wg-mullvad" = {
    ips = [ "10.69.143.223/32" ];
    mtu = 1420;
    table = "100";
    privateKeyFile = "/etc/nixos/secrets/orac_mullvad.key";

    peers = [
      {
        publicKey = "zqsfGglzJPY657WMRxf/S4omG7+ZkSDIpDq+ggbc9yo=";
        allowedIPs = [ "0.0.0.0/0" ];
        endpoint = "23.234.72.2:51820";
        persistentKeepalive = 25;
      }
    ];
  };

  # Push ONLY laptop-originated traffic into table 100 (out via Mullvad).
  # /32 rules so orac's own traffic (AdGuard upstreams etc.) is untouched.
  networking.localCommands = ''
    ip rule add from 10.200.0.2/32 lookup 100 priority 3000 || true
    ip rule add from 10.0.100.4/32 not to 10.0.100.0/24 lookup 100 priority 2400 || true
  '';

  networking.firewall.allowedUDPPorts = [ 443 ];
  networking.firewall.trustedInterfaces = [ "wg0" "wg-mullvad" ];

  networking.firewall.extraCommands = ''
    iptables -A FORWARD -i wg0 -j ACCEPT
    iptables -A FORWARD -i wg-mullvad -j ACCEPT
    iptables -t nat -A POSTROUTING -s 10.200.0.0/24 -j MASQUERADE
    iptables -t nat -A POSTROUTING -s 10.0.100.0/24 -j MASQUERADE
    iptables -t nat -A POSTROUTING -s 10.67.3.187/32 -j MASQUERADE
    iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1200
  '';
}
