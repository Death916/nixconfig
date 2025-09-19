{
  config,
  pkgs,
  lib,
  unstablePkgsHA,
  ...
}:

with lib;

let
  cfg = config.arrSuite;
  unpackerrCfg = cfg.unpackerr;
in
{
  options.arrSuite = {
    enable = mkEnableOption "Enable Sonarr, Radarr, Readarr, and Prowlarr suite";
    unpackerr = {
      enable = mkEnableOption "Enable Unpackerr service";
      configFile = mkOption {
        type = types.path;
        default = "/etc/unpackerr/unpackerr.conf";
        description = "Path to the unpackerr.conf file.";
      };
    };
  };

  config = mkIf cfg.enable {
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

    systemd.tmpfiles.rules = mkIf unpackerrCfg.enable [
      "d /var/log/unpackerr 0755 unpackerr media_services - -"
    ];

    systemd.services.unpackerr = mkIf unpackerrCfg.enable {
      description = "Unpackerr Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = "unpackerr";
        Group = "media_services";
        ExecStart = "${pkgs.unpackerr}/bin/unpackerr --config ${unpackerrCfg.configFile}";
      };
    };
  };
}
