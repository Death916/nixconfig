# Auto-generated using compose2nix v0.3.1.
{ pkgs, lib, ... }:

let
  crowdsecTraefikConfig = pkgs.writeText "crowdsec-traefik.yml" ''
    http:
      middlewares:
        traefik-bouncer:
          plugin:
            traefik-bouncer:
              enabled: true
              crowdsecMode: stream
              crowdsecLapiScheme: http
              crowdsecLapiHost: "172.17.0.1:8080"
              crowdsecLapiKey: '{{ env "BOUNCER_API_KEY" }}'
  '';
in
{
   # Runtime
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };
  virtualisation.oci-containers.backend = "docker";
  # Containers
  virtualisation.oci-containers.containers."gerbil" = {
    image = "fosrl/gerbil:latest";
    volumes = [
      "/var/lib/pangolin/config:/var/config:rw"
    ];
    ports = [
      "51820:51820/udp"
      "443:443/tcp"
      "80:80/tcp"
    ];
    cmd = [
      "--reachableAt=http://gerbil:3003"
      "--generateAndSaveKeyTo=/var/config/key"
      "--remoteConfig=http://pangolin:3001/api/v1/gerbil/get-config"
      "--reportBandwidthTo=http://pangolin:3001/api/v1/gerbil/receive-bandwidth"
    ];
    dependsOn = [
      "pangolin"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--cap-add=SYS_MODULE"
      "--network-alias=gerbil"
      "--network=pangolin"
    ];
  };
  systemd.services."docker-gerbil" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-pangolin.service"
    ];
    requires = [
      "docker-network-pangolin.service"
    ];
    partOf = [
      "docker-compose-pangolin-root.target"
    ];
    wantedBy = [
      "docker-compose-pangolin-root.target"
    ];
  };
  virtualisation.oci-containers.containers."pangolin" = {
    image = "fosrl/pangolin:latest";
    volumes = [
      "/var/lib/pangolin/config:/app/config:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=[\"curl\", \"-f\", \"http://localhost:3001/api/v1/\"]"
      "--health-interval=3s"
      "--health-retries=15"
      "--health-timeout=3s"
      "--network-alias=pangolin"
      "--network=pangolin"
    ];
  };
  systemd.services."docker-pangolin" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-pangolin.service"
    ];
    requires = [
      "docker-network-pangolin.service"
    ];
    partOf = [
      "docker-compose-pangolin-root.target"
    ];
    wantedBy = [
      "docker-compose-pangolin-root.target"
    ];
  };
  virtualisation.oci-containers.containers."traefik" = {
    image = "traefik:v3.4.0";
    environmentFiles = [
      "/var/lib/pangolin/config/traefik/bouncer.env"
    ];
    volumes = [
      "/var/lib/pangolin/config/letsencrypt:/letsencrypt:rw"
      "/var/lib/pangolin/config/traefik:/etc/traefik:ro"
      "/var/lib/pangolin/config/logs:/var/log/traefik:rw"
      "/var/lib/pangolin/config/traefik/dynamic_config.yml:/etc/traefik/conf.d/dynamic_config.yml:ro"
      "${crowdsecTraefikConfig}:/etc/traefik/conf.d/crowdsec.yml:ro"
    ];
    cmd = [
      "--configFile=/etc/traefik/traefik_config.yml"
      "--accesslog=true"
      "--accesslog.filepath=/var/log/traefik/access.log"
      "--experimental.plugins.traefik-bouncer.moduleName=github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin"
      "--experimental.plugins.traefik-bouncer.version=v1.3.5"
      "--providers.file.directory=/etc/traefik/conf.d"
    ];
    dependsOn = [
      "gerbil"
      "pangolin"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network=container:gerbil"
    ];
  };
  systemd.services."docker-traefik" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    partOf = [
      "docker-compose-pangolin-root.target"
    ];
    wantedBy = [
      "docker-compose-pangolin-root.target"
    ];
  };

  virtualisation.oci-containers.containers."traefik-agent" = {
    image = "hhftechnology/traefik-log-dashboard-agent:latest";
    volumes = [
      "/var/lib/pangolin/config/logs-agent:/data:rw"
      "/var/lib/pangolin/config/logs:/logs:ro"
    ];
    ports = [
      "5000:5000"
    ];
    environment = {
      TRAEFIK_LOG_DASHBOARD_ACCESS_PATH = "/logs/access.log";
      TRAEFIK_LOG_DASHBOARD_ERROR_PATH = "/logs/traefik.log";
      TRAEFIK_LOG_DASHBOARD_AUTH_TOKEN = "PANGOLIN_LOGS_TOKEN";
      TRAEFIK_LOG_DASHBOARD_SYSTEM_MONITORING = "true";
      TRAEFIK_LOG_DASHBOARD_GEOIP_ENABLED = "false";
      TRAEFIK_LOG_DASHBOARD_LOG_FORMAT = "json";
      PORT = "5000";
    };
    log-driver = "journald";
    extraOptions = [
      "--health-cmd=[\"wget\", \"--no-verbose\", \"--tries=1\", \"--spider\", \"http://localhost:5000/api/logs/status\"]"
      "--health-interval=30s"
      "--health-retries=3"
      "--health-start-period=10s"
      "--health-timeout=10s"
      "--network-alias=traefik-agent"
      "--network=pangolin"
    ];
  };
  systemd.services."docker-traefik-agent" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-pangolin.service"
    ];
    requires = [
      "docker-network-pangolin.service"
    ];
    partOf = [
      "docker-compose-pangolin-root.target"
    ];
    wantedBy = [
      "docker-compose-pangolin-root.target"
    ];
  };
  virtualisation.oci-containers.containers."traefik-dashboard" = {
    image = "hhftechnology/traefik-log-dashboard:latest";
    ports = [
      "3055:3055"
    ];
    environment = {
      AGENT_API_URL = "http://traefik-agent:5000";
      AGENT_API_TOKEN = "PANGOLIN_LOGS_TOKEN";
      NODE_ENV = "production";
      PORT = "3055";
    };
    dependsOn = [
      "traefik-agent"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=traefik-dashboard"
      "--network=pangolin"
    ];
  };
  systemd.services."docker-traefik-dashboard" = {
    serviceConfig = {
      Restart = lib.mkOverride 90 "always";
      RestartMaxDelaySec = lib.mkOverride 90 "1m";
      RestartSec = lib.mkOverride 90 "100ms";
      RestartSteps = lib.mkOverride 90 9;
    };
    after = [
      "docker-network-pangolin.service"
    ];
    requires = [
      "docker-network-pangolin.service"
    ];
    partOf = [
      "docker-compose-pangolin-root.target"
    ];
    wantedBy = [
      "docker-compose-pangolin-root.target"
    ];
  };

  # Networks
  systemd.services."docker-network-pangolin" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f pangolin";
    };
    script = ''
      docker network inspect pangolin || docker network create pangolin --driver=bridge
    '';
    partOf = [ "docker-compose-pangolin-root.target" ];
    wantedBy = [ "docker-compose-pangolin-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."docker-compose-pangolin-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
