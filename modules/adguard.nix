{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    systemd.tmpfiles.rules = [
      "d /var/lib/AdGuardHome/data 0700 adguardhome adguardhome -"
    ];

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
            "192.168.0.116"
            "100.65.36.116"
          ];
          port = 53;
          upstream_dns = [
            "9.9.9.9"
            "8.8.8.8"
            "100.100.100.100"
          ];
          bootstrap_dns = [
            "9.9.9.9"
            "8.8.4.4"
          ];
        };
        filtering = {
          protection_enabled = true;
          filtering_enabled = true;
          parental_enabled = false;
          safe_search = {
            enabled = false;
          };
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
  };
}
