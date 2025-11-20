{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    services.adguardhome = {
      enable = true;
      openFirewall = true;
      mutableSettings = true;
      settings = {
        http = {
          address = "127.0.0.1:3000";
        };
        dns = {
          upstream_dns = [
            "9.9.9.9"
            "8.8.8.8"
            "100.100.100.100"
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
