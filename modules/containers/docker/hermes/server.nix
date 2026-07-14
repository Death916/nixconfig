# modules/containers/docker/hermes/server.nix
# Standalone Hermes AI agent gateway service for the VPS (ARM proxy/server)
#
# First-time setup on VPS:
#   sudo mkdir -p /var/lib/hermes/data
#   sudo touch /var/lib/hermes/hermes.env
#   # then populate hermes.env with OPENAI_BASE_URL, API keys, etc.

{ pkgs, lib, ... }:

{
  virtualisation.oci-containers.backend = "docker";

  # ── Hermes agent ─────────────────────────────────────────────────────────
  virtualisation.oci-containers.containers."hermes" = {
    image = "docker.io/nousresearch/hermes-agent:latest";
    pull = "always";

    cmd = [
      "gateway"
      "run"
    ];

    environment = {
      "HERMES_HOME" = "/opt/data";
      "API_SERVER_ENABLED" = "true";
      "API_SERVER_KEY" = "local-agent-key"; # Static key for dashboard auth (override in hermes.env)
      "HERMES_DASHBOARD" = "1";
      "HERMES_DASHBOARD_INSECURE" = "1";
      "OPENAI_API_KEY" = "local";
    };

    volumes = [
      # Mount the persistent host directory to the container.
      # Group permissions (2770) and user ownership (10000:users) must match
      # host configurations to allow container write operations.
      "/var/lib/hermes/data:/opt/data:rw"
      "/var/lib/hermes/recall:/opt/data/recall:rw"
      "/mnt/myjfs/gallery:/mnt/myjfs/gallery:rw"
      "/home/death916/prod/deathsite/.web:/deathsite/.web:rw"
    ];

    # Load secrets and backend API URLs from a file on the VPS disk.
    environmentFiles = [ "/var/lib/hermes/hermes.env" ];

    ports = [
      "8642:8642/tcp" # Hermes API
      "9119:9119/tcp" # Hermes dashboard / Web UI
    ];

    log-driver = "journald";
  };

  systemd.services."docker-hermes" = {
    serviceConfig.Restart = lib.mkOverride 90 "on-failure";
    partOf = [ "docker-compose-hermes-server-root.target" ];
    wantedBy = [ "docker-compose-hermes-server-root.target" ];
  };

  # ── Root target ───────────────────────────────────────────────────────────
  systemd.targets."docker-compose-hermes-server-root" = {
    unitConfig.Description = "Standalone Hermes AI agent gateway service";
    wantedBy = [ "multi-user.target" ];
  };

  # ── Persistent storage dirs ───────────────────────────────────────────────
  # Sets permissions to 2770 and owner to UID 10000 (standard for the container)
  # to align with your local host-copied configuration folder.
  systemd.tmpfiles.rules = [
    "d /var/lib/hermes          0755 root root -"
    "d /var/lib/hermes/data     2770 10000 users -"
    "d /var/lib/hermes/recall   2770 10000 users -"
    "f /var/lib/hermes/hermes.env 0600 root root -"
  ];

  # ───────────────────────────────────────────────────────────────────────────
  # ── LOCAL LAPTOP CONFIGURATIONS (Commented out for later use) ──────────────
  # ───────────────────────────────────────────────────────────────────────────
  #
  #  # 1. Ephemeral Screen Capture RAM Disk
  #  # Prevent physical disk thrashing from continuous screenshot writes
  #  fileSystems."/mnt/ramdisk/screenpipe" = {
  #    device = "tmpfs";
  #    fsType = "tmpfs";
  #    options = [ "size=2G" "noatime" ];
  #  };
  #
  #  # 2. Screenpipe background logging service
  #  systemd.services.screenpipe = {
  #    description = "Screenpipe local context recording daemon";
  #    after = [ "network.target" ];
  #    wantedBy = [ "multi-user.target" ];
  #    serviceConfig = {
  #      ExecStart = "${pkgs.screenpipe}/bin/screenpipe --data-dir /mnt/ramdisk/screenpipe --use-local-ocr --disable-audio";
  #      Restart = "always";
  #      User = "death916";
  #    };
  #  };
}
