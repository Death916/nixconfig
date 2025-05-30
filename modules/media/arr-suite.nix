{ config, pkgs, lib, ... }:

{
  options.arrSuite = {
    enable = lib.mkEnableOption "Enable Sonarr, Radarr, Readarr, and Prowlarr suite";
  };

  config = lib.mkIf config.arrSuite.enable {
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
     # extraGroups = [ "media_services" ];
    };
   # users.groups.prowlarr = {};
   
    environment.systemPackages = [
      pkgs.unpackerr
  ];
    users.groups.unpackerr = {};

    # 2. Define the 'unpackerr' user
    users.users.unpackerr = {
      description = "Unpackerr daemon user";
      isSystemUser = true;  # This tells NixOS it's a system user
      group = "unpackerr";  # Sets the primary group
      extraGroups = [ "media_services" ]; # Add 
    };     
    users.groups.radarr = {};
    users.groups.sonarr = {};
    users.groups.readarr = {};
    users.users.sonarr.extraGroups = [ "media_services" ];
    users.users.radarr.extraGroups = [ "media_services" ];
    users.users.readarr.extraGroups = [ "media_services" ];
    #users.users.prowlarr.extraGroups = [ "media_services" ];

   

    systemd.tmpfiles.rules = [
      "d /storage/services/sonarr 0755 sonarr sonarr - -"
      "d /storage/services/radarr 0755 radarr radarr - -"
      "d /storage/services/readarr 0755 readarr readarr - -"
      "d /storage/services/prowlarr 0755 prowlarr prowlarr - -"
    ];

    
  };
}
