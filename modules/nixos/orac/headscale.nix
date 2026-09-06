{ config, pkgs, unstablePkgs, ... }:
{
  services.headscale = {
    enable = true;
    package = unstablePkgs.headscale;
    address = "127.0.0.1";
    port = 8085;

    settings = {
      server_url = "https://ts.death916.xyz";
      metrics_listen_addr = "127.0.0.1:9090";
      trusted_proxies = [
        "127.0.0.1/32"
        "::1/128"
      ];

      dns = {
        magic_dns = true;
        base_domain = "ts.internal";
        nameservers.global = [ ];
      };

      derp = {
        server = {
          enabled = true;
          region_id = 999;
          region_code = "orac";
          region_name = "orac derp";
          verify_clients = true;
          stun_listen_addr = "0.0.0.0:3478";
        };
        urls = [ "https://controlplane.tailscale.com/derpmap/default" ];
        auto_update_enabled = true;
      };

      database.type = "sqlite";
      database.sqlite.write_ahead_log = true;
    };
  };

  networking.firewall.allowedUDPPorts = [ 3478 ];
  environment.systemPackages = [ unstablePkgs.headscale ];
}

