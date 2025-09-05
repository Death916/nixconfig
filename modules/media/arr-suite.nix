{
  config,
  pkgs,
  lib,
  unstablePkgsHA,
  ...
}:

{
  options.arrSuite = {
    enable = lib.mkEnableOption "Enable Sonarr, Radarr, Readarr, and Prowlarr suite";
  };

  config = lib.mkIf config.arrSuite.enable {
    # Define a common group for media services
    users.groups.media_services = { };

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
      package = unstablePkgsHA.prowlarr;
    };

    # Define users and groups
    users.users.sonarr = {
      isSystemUser = true;
      group = "sonarr";
      extraGroups = [ "media_services" ];
    };
    users.groups.sonarr = { };

    users.users.radarr = {
      isSystemUser = true;
      group = "radarr";
      extraGroups = [ "media_services" ];
    };
    users.groups.radarr = { };

    users.users.readarr = {
      isSystemUser = true;
      group = "readarr";
      extraGroups = [ "media_services" ];
    };
    users.groups.readarr = { };

    users.users.prowlarr = {
      isSystemUser = true;
      group = "prowlarr";
      extraGroups = [ "media_services" ];
    };
    users.groups.prowlarr = { };

    # Configure unpackerr
    environment.systemPackages = [ pkgs.unpackerr ];
    users.users.unpackerr = {
      description = "Unpackerr daemon user";
      isSystemUser = true;
      group = "media_services";
    };
  };
}
