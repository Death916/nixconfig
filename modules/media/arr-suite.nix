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
    };
    services.radarr = {
      enable = true;
      openFirewall = false;
      dataDir = "/storage/services/radarr";
    };
    services.readarr = {
      enable = true;
      openFirewall = false;
      dataDir = "/storage/services/readarr";
    };
    services.prowlarr = {
      enable = true;
      openFirewall = false;
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
