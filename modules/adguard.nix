{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    # systemd.tmpfiles.rules = [
    # "d /var/lib/AdGuardHome/data 0700 adguardhome adguardhome -"
    # ];

    services.adguardhome = {
      enable = true;
      openFirewall = true;
      mutableSettings = true;
      settings = {
        http = {
          address = "127.0.0.1:3000";
        };
        dns = {
          bind_hosts = [
            "0.0.0.0"
          ];
          port = 53;
          upstream_dns = [
            "9.9.9.9"
            "8.8.8.8"
          ];
          bootstrap_dns = [
            "9.9.9.9"
            "8.8.4.4"
          ];
          rewrites = [
            { domain = "orac.death"; answer = "10.0.100.1"; enabled = true; }
            { domain = "homelab.death"; answer = "10.0.100.2"; enabled = true; }
            { domain = "desktop.death"; answer = "10.0.100.3"; enabled = true; }
            { domain = "laptop.death"; answer = "10.0.100.4"; enabled = true; }
            { domain = "orac"; answer = "10.0.100.1"; enabled = true; }
            { domain = "homelab"; answer = "10.0.100.2"; enabled = true; }
            { domain = "desktop"; answer = "10.0.100.3"; enabled = true; }
            { domain = "laptop"; answer = "10.0.100.4"; enabled = true; }
          ];
        };
        filtering = {
          protection_enabled = true;
          filtering_enabled = true;
          parental_enabled = false;
          safe_search = {
            enabled = false;
          };
          rewrites = [
            { domain = "orac.death"; answer = "10.0.100.1"; enabled = true; }
            { domain = "homelab.death"; answer = "10.0.100.2"; enabled = true; }
            { domain = "desktop.death"; answer = "10.0.100.3"; enabled = true; }
            { domain = "laptop.death"; answer = "10.0.100.4"; enabled = true; }
            { domain = "orac"; answer = "10.0.100.1"; enabled = true; }
            { domain = "homelab"; answer = "10.0.100.2"; enabled = true; }
            { domain = "desktop"; answer = "10.0.100.3"; enabled = true; }
            { domain = "laptop"; answer = "10.0.100.4"; enabled = true; }
          ];
        };
        filters =
          lib.map
            (url: {
              enabled = true;
              url = url;
            })
            [
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"
              "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"
            ];
      };
    };

    systemd.services.adguardhome.after = [ "network-online.target" "tailscaled.service" "nebula@deathmesh.service" ];
    systemd.services.adguardhome.requires = [ "network-online.target" "tailscaled.service" "nebula@deathmesh.service" ];
  };
}
