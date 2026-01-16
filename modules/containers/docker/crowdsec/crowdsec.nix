{ config, pkgs, ... }:

let
  configDir = "/var/lib/crowdsec/config";
  dataDir = "/var/lib/crowdsec/data";
  bouncerEnvFile = "/var/lib/crowdsec/bouncer.env";

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
    "f ${bouncerEnvFile} 0600 root root -"
  ];

  virtualisation.oci-containers.containers.crowdsec = {
    image = "crowdsecurity/crowdsec:latest";
    autoStart = true;
    ports = [ "127.0.0.1:8080:8080" ];
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

  services.crowdsec-firewall-bouncer = {
    enable = true;

    settings = {
      mode = "iptables";
      log_level = "info";
      update_frequency = "10s";
      api_url = "http://127.0.0.1:8080/";
      api_key = "\${BOUNCER_API_KEY}";
      iptables_chains = [ "INPUT" "DOCKER-USER" ];
    };
  };

  systemd.services.crowdsec-firewall-bouncer.serviceConfig = {
    EnvironmentFile = bouncerEnvFile;
    Environment = [ "CREDENTIALS_DIRECTORY=/var/lib/crowdsec" ];
  };

}
