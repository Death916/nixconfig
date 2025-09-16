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
in
{
  options.arrSuite = {
    enable = mkEnableOption "Enable Sonarr, Radarr, Readarr, and Prowlarr suite";
    unpackerr = {
      enable = mkEnableOption "Enable Unpackerr service";
      downloadPath = mkOption {
        type = types.str;
        default = "/media/storage/media/downloads";
        description = "Path to the download directory to watch.";
      };
      extractPath = mkOption {
        type = types.str;
        default = "";
        description = "Path to extract files to. Leave empty to extract in place.";
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

    systemd.services.unpackerr = mkIf cfg.unpackerr.enable {
      description = "Unpackerr Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = "unpackerr";
        Group = "media_services";
        ExecStart = ''
          ${pkgs.unpackerr}/bin/unpackerr --config ${
            pkgs.writeText "unpackerr.conf" ''
              [unpackerr]
              log_file = "/var/log/unpackerr.log"
              log_files = 10
              log_file_mb = 10
              [[folder]]
              path = "${cfg.unpackerr.downloadPath}"
              extract_path = "${cfg.unpackerr.extractPath}"
            ''
          }
        '';
      };
    };
  };
}
