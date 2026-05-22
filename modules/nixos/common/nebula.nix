{ config, pkgs, ... }: {
  services.nebula.networks.deathmesh = {
    enable = true;
    listen.port = 4242;
    settings.tun.dev = "dmesh0";

    firewall.inbound = [
      { port = "any"; proto = "icmp"; host = "any"; }
      { port = "any"; proto = "any"; host = "any"; }
    ];
    firewall.outbound = [
      { port = "any"; proto = "any"; host = "any"; }
    ];
  };

  networking.firewall.trustedInterfaces = [ "dmesh0" ];
  networking.firewall.allowedUDPPorts = [ 4242 ];
  networking.firewall.checkReversePath = "loose";

  networking.localCommands = ''
    ip rule add to 10.0.100.0/24 priority 2500 lookup main
  '';
}
