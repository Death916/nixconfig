{ config, pkgs, ... }:

{
  services.crowdsec = {
    enable = true;

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

    settings = {
      common = {
        log_media = "stdout";
      };
      api = {
        client = {
          credentials_path = "/var/lib/crowdsec/lapi-credentials.yaml";
        };
        server = {
          enable = true;
          listen_uri = "127.0.0.1:8080";
        };
      };
    };

    hub = {
      collections = [
        "crowdsecurity/linux"
        "crowdsecurity/sshd"
        "crowdsecurity/traefik"
        "crowdsecurity/http-cve"
      ];
    };
  };

  services.crowdsec-firewall-bouncer = {
    enable = true;

    registerBouncer = {
      enable = true;
    };

    settings = {
      mode = "nftables";
      log_level = "info";
      update_frequency = "10s";
      api_url = "http://127.0.0.1:8080/";
    };
  };

  users.users.crowdsec.extraGroups = [ "systemd-journal" ];

  systemd.tmpfiles.rules = [
    "d /var/lib/crowdsec 0750 crowdsec crowdsec -"
  ];
}
