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
      "BASE_URL" = "http://orac:8100";
      "MINUSPOD_PORT" = "8000";
      "MAX_AUDIO_DOWNLOAD_MB" = "500";
      "SESSION_COOKIE_SECURE" = "false";
    };

    volumes = [
      "/var/lib/minuspod:/app/data:rw"
      # Media library lives on JuiceFS (/mnt/myjfs — S3-backed, 1PB, ~1% used)
      # so it can never fill the 91G root fs. The CONTAINER path is unchanged
      # (/app/data/podcasts) and podcast.db stores RELATIVE paths
      # (episodes/<hash>-v1.mp3, logs/...), verified 2026-10-14: no DB row
      # references /var/lib/minuspod, so nothing needs re-pointing.
      # podcast.db + -wal deliberately stay on root (sqlite/WAL over FUSE is a
      # corruption risk for zero real gain — they are ~850M, not the problem).
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
      Restart = lib.mkOverride 90 "on-failure";
      RestartSec = lib.mkOverride 90 "5s";
    };
    after = [ "docker-network-hermes_net.service" ];
    requires = [ "docker-network-hermes_net.service" ];
    partOf = [ "docker-compose-hermes-server-root.target" ];
    wantedBy = [ "docker-compose-hermes-server-root.target" ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/minuspod 0755 root root -"
    "d /mnt/myjfs/minuspod/podcasts 0755 root root -"
  ];
}
