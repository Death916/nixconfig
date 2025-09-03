{ config, pkgs, lib, ... }:

{
  options.arrSuite = {
    enable = lib.mkEnableOption "Enable Sonarr, Radarr, Readarr, and Prowlarr suite";
  };

  config = lib.mkIf config.arrSuite.enable {
    # Define a common group for media services
    users.groups.media_services = {};

    # Enable and configure the arr services
    services.sonarr = {
      enable = true;
      openFirewall = false;
      dataDir = "/storage/services/sonarr";
      group = "media_services";
    };
    services.radarr = {
      enable = true;
      openFirewall = false;
      dataDir = "/storage/services/radarr";
      group = "media_services";
    };
    services.readarr = {
      enable = true;
      openFirewall = false;
      dataDir = "/storage/services/readarr";
      group = "media_services";
    };
    services.prowlarr = {
      enable = true;
      openFirewall = false;
      group = "media_services";
    };

    # Add users to the media group
    users.users.sonarr.extraGroups = [ "media_services" ];
    users.users.radarr.extraGroups = [ "media_services" ];
    users.users.readarr.extraGroups = [ "media_services" ];
    users.users.prowlarr.extraGroups = [ "media_services" ];

    # Configure unpackerr
    environment.systemPackages = [ pkgs.unpackerr ];
    users.users.unpackerr = {
      description = "Unpackerr daemon user";
      isSystemUser = true;
      group = "media_services";
    };
  };
}
