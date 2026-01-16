{ config, pkgs, ... }:

{
  # 1. Enable the CrowdSec Security Engine
  services.crowdsec = {
    enable = true;

    # Automated hub management
    hub = {
      collections = [
        "crowdsecurity/linux"    # Base linux protection
        "crowdsecurity/sshd"     # SSH brute force
        "crowdsecurity/traefik"  # Traefik log parsing
        "crowdsecurity/http-cve" # Generic HTTP attacks
      ];
    };

    # 2. Configure log sources (Acquisitions)
    localConfig.acquisitions = [
      # Monitor SSH and System Auth via Systemd Journal
      {
        source = "journalctl";
        journalctl_filter = [ "_SYSTEMD_UNIT=sshd.service" ];
        labels.type = "syslog";
      }
      {
        source = "journalctl";
        journalctl_filter = [ "SYSLOG_IDENTIFIER=sudo" "SYSLOG_IDENTIFIER=auth" ];
        labels.type = "syslog";
      }

      # Monitor Traefik logs from Docker via Journald
      {
        source = "journalctl";
        journalctl_filter = [ "_SYSTEMD_UNIT=docker-traefik.service" ]; # Matches your Traefik service unit
        labels.type = "traefik";
      }
    ];

    # Required for the Local API (LAPI) to function
    settings = {
      api.server.enable = true;
    };
  };

  # 3. Enable the Firewall Bouncer (Remediation)
  services.crowdsec-firewall-bouncer = {
    enable = true;
    
    settings = {
      # Automatically register the bouncer with the local CrowdSec engine
      # This generates the API key for you.
      registerBouncer = true;
      mode = "nftables"; # Modern NixOS uses nftables by default
      log_level = "info";
      update_frequency = "10s";
      
      # The API URL for the local engine
      api_url = "http://127.0.0.1:8080/";
    };
  };

  # 4. Permissions: Ensure CrowdSec can read logs from systemd-journal
  # The crowdsec service runs as its own user. It needs to be in the 'systemd-journal' group 
  # to read journalctl logs.
  users.users.crowdsec.extraGroups = [ "systemd-journal" ];
}
