{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.qbittorrent;
in
{
  options.services.qbittorrent = {
    enable = mkEnableOption "qBittorrent-nox headless service";

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/qbittorrent";
      description = "Directory where qBittorrent stores its data files.";
    };

    user = mkOption {
      type = types.str;
      default = "qbittorrent";
      description = "User account under which qBittorrent runs.";
    };

    group = mkOption {
      type = types.str;
      default = "media_services";
      description = "Group under which qBittorrent runs.";
    };

    port = mkOption {
      type = types.port;
      default = 8080;
      description = "qBittorrent web UI port.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open the web UI port to the network.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.qbittorrent-nox;
      defaultText = literalExpression "pkgs.qbittorrent-nox";
      description = "The qbittorrent package to use.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };

    systemd.services.qbittorrent = {
      description = "qBittorrent-nox service";
      documentation = [ "man:qbittorrent-nox(1)" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStartPre = let
          preStartScript = pkgs.writeScript "qbittorrent-prestart" ''
            #!${pkgs.bash}/bin/bash
            if ! test -d "$QBT_PROFILE"; then
              install -d -m 0755 -o "${cfg.user}" -g "${cfg.group}" "$QBT_PROFILE"
            fi
          '';
        in
          "!${preStartScript}";
        ExecStart = "${cfg.package}/bin/qbittorrent-nox";
      };
      environment = {
        QBT_PROFILE = cfg.dataDir;
        QBT_WEBUI_PORT = toString cfg.port;
      };
    };

    users.users = mkIf (cfg.user == "qbittorrent") {
      qbittorrent = {
        group = cfg.group;
        extraGroups = [ "media_services" ];
      };
    };

    users.groups = mkIf (cfg.group == "qbittorrent") {
      qbittorrent = {};
    };
  };
}
