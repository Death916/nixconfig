{ config, pkgs, ... }:

{
  services.crowdsec = {
    enable = true;

    hub.collections = [
      "crowdsecurity/linux"
      "crowdsecurity/sshd"
      "crowdsecurity/traefik"
      "crowdsecurity/http-cve"
    ];

    localConfig = {
      acquisitions = [
        {
          source = "journalctl";
          journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
          labels.type = "syslog";
        }
        {
          source = "journalctl";
          journalctl_filter = [
            "SYSLOG_IDENTIFIER=sudo"
            "SYSLOG_IDENTIFIER=auth"
          ];
          labels.type = "syslog";
        }
        {
          source = "journalctl";
          journalctl_filter = [ "_SYSTEMD_UNIT=docker-traefik.service" ];
          labels.type = "traefik";
        }
      ];
    };

    settings.general = {
      api.server.enable = true;
    };
  };

  services.crowdsec-firewall-bouncer = {
    enable = true;

    registerBouncer.enable = true;

    settings = {
      mode = "nftables";
      log_level = "info";
      update_frequency = "10s";
      api_url = "http://127.0.0.1:8080/";
    };
  };

  users.users.crowdsec.extraGroups = [ "systemd-journal" ];
}
