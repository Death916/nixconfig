{ config, pkgs, ... }:

let
  lighthouseIp = "167.234.220.107";
  sshPort = 22; # Fortinet might eventually block 22, so we can change this to 443 later if needed.
  sshUser = "death916";
  sshKey = "/home/death916/.ssh/id_ed25519";
in
{
  environment.systemPackages = [ pkgs.tun2socks pkgs.iproute2 pkgs.gawk ];

  # 1. The SSH Tunnel Service
  systemd.services.lighthouse-proxy = {
    description = "SSH SOCKS5 Proxy to Lighthouse";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    
    serviceConfig = {
      # Creates local SOCKS5 proxy on port 1080.
      ExecStart = "${pkgs.openssh}/bin/ssh -NT -D 1080 -o StrictHostKeyChecking=accept-new -o ExitOnForwardFailure=yes -p ${toString sshPort} -i ${sshKey} ${sshUser}@${lighthouseIp}";
      Restart = "always";
      RestartSec = "5s";
      User = "${sshUser}";
    };
  };

  # 2. The Tun2Socks Engine
  systemd.services.tun2socks-vpn = {
    description = "Transparent SOCKS5 VPN via tun2socks";
    wantedBy = [ "multi-user.target" ];
    requires = [ "lighthouse-proxy.service" ];
    after = [ "lighthouse-proxy.service" ];
    
    # We must run this as root to manage interfaces and routes
    serviceConfig = {
      Type = "simple";
      
      # Step 1: Create the interface and bypass the routing loop.
      # We route Lighthouse traffic directly to the physical gateway.
      ExecStartPre = [
        # Clean up any stale interfaces before starting
        "-${pkgs.iproute2}/bin/ip link del dev tun0"
        
        # Create interface
        "${pkgs.iproute2}/bin/ip tuntap add mode tun dev tun0"
        "${pkgs.iproute2}/bin/ip addr add 198.18.0.1/15 dev tun0"
        "${pkgs.iproute2}/bin/ip link set dev tun0 up"
        
        # Bypass Infinite Loop: Route Lighthouse explicitly through the default physical gateway
        "${pkgs.bash}/bin/bash -c 'GATEWAY=$(${pkgs.iproute2}/bin/ip route | grep default | grep -v tun0 | awk \"{print \\$3}\" | head -n 1); IFACE=$(${pkgs.iproute2}/bin/ip route | grep default | grep -v tun0 | awk \"{print \\$5}\" | head -n 1); ${pkgs.iproute2}/bin/ip route add ${lighthouseIp} via $$GATEWAY dev $$IFACE'"
      ];

      # Step 2: Start tun2socks
      ExecStart = "${pkgs.tun2socks}/bin/tun2socks -device tun://tun0 -proxy socks5://127.0.0.1:1080";

      # Step 3: Route all other internet traffic into tun0
      ExecStartPost = [
        # Sleep for a second to ensure tun2socks is listening before hijacking default route
        "${pkgs.coreutils}/bin/sleep 1"
        "${pkgs.iproute2}/bin/ip route add default dev tun0 metric 1"
      ];

      # Clean up when stopped so we don't break networking!
      ExecStopPost = [
        "-${pkgs.iproute2}/bin/ip route del default dev tun0 metric 1"
        "-${pkgs.bash}/bin/bash -c 'GATEWAY=$(${pkgs.iproute2}/bin/ip route | grep default | grep -v tun0 | awk \"{print \\$3}\" | head -n 1); IFACE=$(${pkgs.iproute2}/bin/ip route | grep default | grep -v tun0 | awk \"{print \\$5}\" | head -n 1); ${pkgs.iproute2}/bin/ip route del ${lighthouseIp} via $$GATEWAY dev $$IFACE'"
        "-${pkgs.iproute2}/bin/ip link del dev tun0"
      ];
      
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
