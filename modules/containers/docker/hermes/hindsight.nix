# modules/containers/docker/hermes/hindsight.nix
# Hindsight long-term memory backend for the Hermes agent on orac (ARM64 Oracle Cloud VPS)
#
# Stack:
#   - hermes-postgres  : pgvector/pgvector:pg17  (vector-enabled Postgres, internal only)
#   - hindsight        : ghcr.io/vectorize-io/hindsight:latest-slim  (no bundled ML models)
#
# All three containers (hermes, hermes-postgres, hindsight) share "hermes_net".
# Hermes reaches Hindsight at http://hindsight:8888 inside that network.
#
# This file merges cleanly with server.nix via the NixOS module system —
# the hermes container's extraOptions and systemd after/requires lists are
# concatenated across both files. server.nix does NOT need to be modified.
#
# ── First-time setup on orac ──────────────────────────────────────────────────
#
#   sudo mkdir -p /var/lib/hermes/postgres /var/lib/hermes/hindsight
#   sudo touch /var/lib/hermes/hindsight.env
#
#   Then populate /var/lib/hermes/hindsight.env:
#
#     # Postgres credentials (used by both hermes-postgres and hindsight)
#     POSTGRES_PASSWORD=<strong-random-password>
#     POSTGRES_USER=hindsight
#     POSTGRES_DB=hindsight
#
#     # Hindsight DB connection (must match creds above)
#     HINDSIGHT_API_DATABASE_URL=postgresql://hindsight:<password>@hermes-postgres:5432/hindsight
#
#     # LLM for Hindsight fact extraction — point at the same API as Hermes
#     HINDSIGHT_API_LLM_PROVIDER=openai
#     HINDSIGHT_API_LLM_BASE_URL=<your-openai-compatible-base-url>
#     HINDSIGHT_API_LLM_API_KEY=<your-api-key>
#     HINDSIGHT_API_LLM_MODEL=<model-name>
#
#     # Auth key Hermes uses to authenticate to Hindsight (generate any secret)
#     HINDSIGHT_API_AUTH_TOKEN=<secret-token>
#
#   And add to /var/lib/hermes/hermes.env:
#
#     HINDSIGHT_API_KEY=<same-secret-token-as-above>
#     HINDSIGHT_API_URL=http://hindsight:8888
#
# ─────────────────────────────────────────────────────────────────────────────

{ pkgs, lib, ... }:

{
  # ── Postgres + pgvector (Hindsight backing store) ─────────────────────────
  # pgvector/pgvector:pg17 ships multi-arch ARM64 images — safe on Oracle Ampere A1.
  # Never exposed on host ports; only reachable inside hermes_net.
  virtualisation.oci-containers.containers."hermes-postgres" = {
    image = "docker.io/pgvector/pgvector:pg17";
    pull = "always";

    environment = {
      # Non-secret DB config — credentials come from hindsight.env below.
      "POSTGRES_DB"   = "hindsight";
      "POSTGRES_USER" = "hindsight";
    };

    volumes = [
      # Persist Postgres data across container restarts / rebuilds.
      "/var/lib/hermes/postgres:/var/lib/postgresql/data:rw"
    ];

    # POSTGRES_PASSWORD is loaded from here (never committed to Nix store).
    environmentFiles = [ "/var/lib/hermes/hindsight.env" ];

    extraOptions = [
      "--network=hermes_net"
      "--network-alias=hermes-postgres"
      # Health check so dependants wait for Postgres to be ready before starting.
      "--health-cmd=pg_isready -U hindsight -d hindsight"
      "--health-interval=5s"
      "--health-timeout=3s"
      "--health-retries=10"
      "--health-start-period=10s"
    ];

    log-driver = "journald";
  };

  systemd.services."docker-hermes-postgres" = {
    serviceConfig = {
      Restart            = lib.mkOverride 90 "on-failure";
      RestartSec         = lib.mkOverride 90 "5s";
    };
    after    = [ "docker-network-hermes_net.service" ];
    requires = [ "docker-network-hermes_net.service" ];
    partOf   = [ "docker-compose-hermes-server-root.target" ];
    wantedBy = [ "docker-compose-hermes-server-root.target" ];
  };

  # ── Hindsight memory server ───────────────────────────────────────────────
  # Uses the slim image — no bundled embedding/reranker models.
  # Embedding calls are offloaded to the same external LLM API as Hermes.
  # Hermes reaches this container at http://hindsight:8888 over hermes_net.
  virtualisation.oci-containers.containers."hindsight" = {
    image = "ghcr.io/vectorize-io/hindsight:latest-slim";
    pull = "always";

    environment = {
      # Use external Postgres — loaded via environmentFiles below:
      #   HINDSIGHT_API_DATABASE_URL
      #   HINDSIGHT_API_LLM_PROVIDER
      #   HINDSIGHT_API_LLM_BASE_URL
      #   HINDSIGHT_API_LLM_API_KEY
      #   HINDSIGHT_API_LLM_MODEL
      #   HINDSIGHT_API_AUTH_TOKEN

      # Use pgvector extension (enabled automatically by the pgvector image).
      "HINDSIGHT_API_VECTOR_EXTENSION" = "pgvector";
    };

    volumes = [
      # Mount a writable dir for any config/state Hindsight writes to disk.
      "/var/lib/hermes/hindsight:/home/hindsight/.hindsight:rw"
    ];

    # All secrets and LLM/DB config come from this file on the host.
    environmentFiles = [ "/var/lib/hermes/hindsight.env" ];

    extraOptions = [
      "--network=hermes_net"
      "--network-alias=hindsight"
      # Wait for Postgres to pass its health check before this container starts.
      "--health-cmd=wget --no-verbose --tries=1 --spider http://localhost:8888/health || exit 1"
      "--health-interval=10s"
      "--health-timeout=5s"
      "--health-retries=6"
      "--health-start-period=15s"
    ];

    log-driver = "journald";
  };

  systemd.services."docker-hindsight" = {
    serviceConfig = {
      Restart    = lib.mkOverride 90 "on-failure";
      RestartSec = lib.mkOverride 90 "5s";
    };
    after    = [
      "docker-network-hermes_net.service"
      "docker-hermes-postgres.service"
    ];
    requires = [
      "docker-network-hermes_net.service"
      "docker-hermes-postgres.service"
    ];
    partOf   = [ "docker-compose-hermes-server-root.target" ];
    wantedBy = [ "docker-compose-hermes-server-root.target" ];
  };

  # ── Attach hermes to hermes_net (merged with server.nix) ─────────────────
  # The NixOS module system concatenates listOf options across modules, so this
  # appends to hermes's extraOptions and the systemd after/requires lists
  # defined in server.nix without touching that file.
  virtualisation.oci-containers.containers."hermes".extraOptions = [
    "--network=hermes_net"
    "--network-alias=hermes"
  ];

  systemd.services."docker-hermes" = {
    after    = [
      "docker-network-hermes_net.service"
      "docker-hindsight.service"
    ];
    requires = [
      "docker-network-hermes_net.service"
      "docker-hindsight.service"
    ];
  };

  # ── Shared Docker network ─────────────────────────────────────────────────
  systemd.services."docker-network-hermes_net" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type             = "oneshot";
      RemainAfterExit  = true;
      ExecStop         = "docker network rm -f hermes_net";
    };
    script = ''
      docker network inspect hermes_net \
        || docker network create hermes_net --driver=bridge
    '';
    partOf   = [ "docker-compose-hermes-server-root.target" ];
    wantedBy = [ "docker-compose-hermes-server-root.target" ];
  };

  # ── Persistent storage dirs ───────────────────────────────────────────────
  systemd.tmpfiles.rules = [
    # Postgres data — owned by the pgvector container's postgres user (UID 999)
    "d /var/lib/hermes/postgres   0700 999 999 -"
    # Hindsight state dir
    "d /var/lib/hermes/hindsight  0755 root root -"
    # Hindsight secrets file (created empty if absent; populate manually)
    "f /var/lib/hermes/hindsight.env 0600 root root -"
  ];
}
