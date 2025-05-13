{ config, pkgs, lib, ... }:

{
  options.arrSuite = {
    enable = lib.mkEnableOption "Enable Sonarr, Readarr, and Prowlarr suite";
  };

  config = lib.mkIf config.arrSuite.enable {
    services.sonarr = {
      enable = true;
      openFirewall = false; #default port 8989
      dataDir = "/storage/services/sonarr";
    };
    services.readarr = {
      enable = true;
      openFirewall = false;  #default port 8787
      dataDir = "/storage/services/readarr";
    };
    services.prowlarr = {
      enable = true;
      openFirewall = false; # port 9696
      dataDir = "/storage/services/prowlarr";
    };

    services.radarr = {
      enable = true;
      openFirewall = false;
      dataDir = "/storage/services/radarr";
    };

    systemd.tmpfiles.rules = [
      "d /storage/services/sonarr 0755 sonarr sonarr - -"
      "d /storage/services/radarr 0755 radarr radarr - -"
      "d /storage/services/readarr 0755 readarr readarr - -"
      "d /storage/services/prowlarr 0755 prowlarr prowlarr - -"
    ];
  };
}
