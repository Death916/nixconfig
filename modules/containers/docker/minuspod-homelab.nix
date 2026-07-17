# modules/containers/docker/minuspod.nix
# MinusPod — podcast ad removal on homelab (x86)
# Whisper via Groq, LLM via OpenCode Go
# Access via Nebula from anywhere

{ pkgs, lib, ... }:

{
  virtualisation.oci-containers.containers."minuspod" = {
    image = "ttlequals0/minuspod:cpu";
    pull = "always";

    environment = {
      "BASE_URL"        = "http://10.0.100.2:8100";
      "MINUSPOD_PORT"   = "8000";
      "MAX_AUDIO_DOWNLOAD_MB" = "500";
      "SESSION_COOKIE_SECURE" = "false";
    };

    volumes = [
      "/storage/services/minuspod/data:/app/data:rw"
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
    unitConfig = {
      RequiresMountsFor = [ "/storage" ];
      ConditionPathIsMountPoint = "/storage";
    };
    after = [ "media.mount" ];
    wants = [ "media.mount" ];
  };

  systemd.tmpfiles.rules = [
    "d /storage/services/minuspod      0755 root root -"
    "d /storage/services/minuspod/data 0755 root root -"
  ];
}
