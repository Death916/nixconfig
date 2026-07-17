# modules/containers/docker/minuspod.nix
# MinusPod — podcast ad removal on orac (VPS)
# Whisper via OpenRouter, LLM via OpenCode Go, ~200-400MB RAM
# Access via Nebula from homelab

{ pkgs, lib, ... }:

{
  virtualisation.oci-containers.containers."minuspod" = {
    image = "ttlequals0/minuspod:cpu";
    pull = "always";

    environment = {
      "BASE_URL"        = "http://10.0.100.1:8100";
      "MINUSPOD_PORT"   = "8000";
      "MAX_AUDIO_DOWNLOAD_MB" = "500";
      "SESSION_COOKIE_SECURE" = "false";
    };

    volumes = [
      "/var/lib/minuspod:/app/data:rw"
      "/mnt/myjfs/minuspod/podcasts:/app/data/podcasts:rw"
    ];

    environmentFiles = [ "/etc/nixos/secrets/minuspod.env" ];

    ports = [
      "8100:8000/tcp"
    ];

    log-driver = "journald";

    extraOptions = [
      "--health-cmd=curl -f http://localhost:8000/api/v1/health || exit 1"
      "--health-interval=30s"
      "--health-timeout=5s"
      "--health-retries=3"
      "--health-start-period=30s"
    ];
  };

  systemd.services."docker-minuspod" = {
    serviceConfig = {
      Restart    = lib.mkOverride 90 "on-failure";
      RestartSec = lib.mkOverride 90 "5s";
    };
    after    = [ "docker-network-hermes_net.service" ];
    requires = [ "docker-network-hermes_net.service" ];
    partOf   = [ "docker-compose-hermes-server-root.target" ];
    wantedBy = [ "docker-compose-hermes-server-root.target" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/minuspod 0755 root root -"
    "d /mnt/myjfs/minuspod/podcasts 0755 root root -"
  ];
}
