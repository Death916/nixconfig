{ config, pkgs, ... }:

let
  crowdsecImage = "crowdsecurity/crowdsec:latest";
  bouncerImage = "crowdsecurity/crowdsec-firewall-bouncer:latest";

  configDir = "/var/lib/crowdsec/config";
  dataDir = "/var/lib/crowdsec/data";
  bouncerDir = "/var/lib/crowdsec/bouncer-data";

  acquisYaml = pkgs.writeText "acquis.yaml" ''
    ---
    source: docker
    container_name:
      - traefik
    labels:
      type: traefik
    ---
    source: journalctl
    journalctl_filter:
      - "_SYSTEMD_UNIT=sshd.service"
    labels:
      type: syslog
    ---
    source: journalctl
    journalctl_filter:
      - "SYSLOG_IDENTIFIER=sudo"
      - "SYSLOG_IDENTIFIER=auth"
    labels:
      type: syslog
  '';

in
{
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  systemd.tmpfiles.rules = [
    "d ${configDir} 0755 root root -"
    "d ${dataDir} 0755 root root -"
    "d ${bouncerDir} 0700 root root -"
    "f ${bouncerDir}/bouncer.env 0600 root root -"
  ];

  virtualisation.oci-containers.containers = {

    crowdsec = {
      image = crowdsecImage;
      autoStart = true;
      environment = {
        COLLECTIONS = "crowdsecurity/linux crowdsecurity/sshd crowdsecurity/traefik crowdsecurity/http-cve";
        GID = "0";
      };
      volumes = [
        "${configDir}:/etc/crowdsec"
        "${dataDir}:/var/lib/crowdsec/data"
        "/var/run/docker.sock:/var/run/docker.sock"
        "/var/log/journal:/var/log/journal:ro"
        "/run/log/journal:/run/log/journal:ro"
        "/etc/machine-id:/etc/machine-id:ro"
        "${acquisYaml}:/etc/crowdsec/acquis.yaml"
      ];
    };

    crowdsec-bouncer = {
      image = bouncerImage;
      autoStart = true;
      extraOptions = [
        "--network=host"
        "--privileged"
      ];
      environment = {
        API_URL = "http://127.0.0.1:8080";
        LOG_LEVEL = "info";
      };
      environmentFiles = [
        "${bouncerDir}/bouncer.env"
      ];
      dependsOn = [ "crowdsec" ];
    };
  };
}
