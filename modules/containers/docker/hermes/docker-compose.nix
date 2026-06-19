# modules/containers/docker/hermes/docker-compose.nix
# Two-container setup for Hermes AI agent on nix-asus:
#   - llama-server: llama.cpp server with ROCm AMD GPU access (inference backend)
#   - hermes:       Hermes agent (orchestration layer, points at llama-server)
#
# Models are stored in /storage/services/hermes/models (bind-mounted).
# Hermes config/state is in /storage/services/hermes/data.
# Secrets (API keys etc.) go in /storage/services/hermes/hermes.env — NOT in the Nix store.
#
# First-time setup:
#   sudo mkdir -p /storage/services/hermes/{models,data}
#   sudo touch /storage/services/hermes/hermes.env
#   # then populate hermes.env with any API keys Hermes needs

{ pkgs, lib, ... }:

let
  modelsIni = pkgs.writeText "models.ini" ''
    [gemma-4-12b-it-qat-q4_0]
    model = /models/gemma-4-12b-it-qat-q4_0.gguf
    ctx-size = 32768
    ngl = 99
    flash-attn = true
    cache-type-k = q8_0
    cache-type-v = q8_0

    [qwen3.6-27b-instruct-Q4_K_M]
    model = /models/qwen3.6-27b-instruct-Q4_K_M.gguf
    ctx-size = 32768
    ngl = 28
    flash-attn = true
    cache-type-k = q8_0
    cache-type-v = q8_0
  '';
in
{
  virtualisation.oci-containers.backend = "docker";

  # ── llama.cpp inference server ──────────────────────────────────────────
  virtualisation.oci-containers.containers."llama-server" = {
    image = "ghcr.io/ggml-org/llama.cpp:server-rocm";
    pull = "always";

    # Pass the AMD GPU devices into the container
    extraOptions = [
      "--device=/dev/kfd"
      "--device=/dev/dri"
      "--group-add=video"
      "--ipc=host"
      "--network=hermes_net"
      "--network-alias=llama-server"
    ];

    environment = {
      # Override GFX version if your iGPU isn't auto-detected by ROCm.
      # For Asus Ryzen AI (e.g. 780M/890M), uncomment and set appropriately:
      "HSA_OVERRIDE_GFX_VERSION" = "11.0.0";
      "AMD_VISIBLE_DEVICES" = "all";
    };

    volumes = [
      # Store GGUF models here — add models manually with e.g.:
      #   docker exec llama-server sh -c "wget -O /models/model.gguf <url>"
      # Or copy them in: docker cp model.gguf llama-server:/models/
      "/var/lib/hermes/models:/models:rw"
      "${modelsIni}:/models/models.ini:ro"
    ];

    # llama-server args — adjust --model path and --ctx-size as needed
    # Launch in Router Mode to allow dynamic model switching
    cmd = [
      "--host" "0.0.0.0"
      "--port" "8080"
      "--models-preset" "/models/models.ini"
      "--models-max" "1"      # Cap VRAM usage to 1 active model at a time
      "--parallel" "1"        # Only 1 slot needed for single-user local agent (saves 75% memory)
      "--cache-type-k" "q8_0" # 8-bit Key cache quantization (lossless quality, reduces VRAM/RAM footprint)
      "--cache-type-v" "q8_0" # 8-bit Value cache quantization
      "--flash-attn" "on"     # flash attention for efficiency
    ];

    ports = [
      "127.0.0.1:8080:8080/tcp"  # only reachable locally; Hermes connects internally
    ];

    log-driver = "journald";
  };

  systemd.services."docker-llama-server" = {
    serviceConfig.Restart = lib.mkOverride 90 "on-failure";
    after    = [ "docker-network-hermes_net.service" ];
    requires = [ "docker-network-hermes_net.service" ];
    partOf   = [ "docker-compose-hermes-root.target" ];
    wantedBy = [ "docker-compose-hermes-root.target" ];
  };

  # ── Hermes agent ─────────────────────────────────────────────────────────
  virtualisation.oci-containers.containers."hermes" = {
    image = "docker.io/nousresearch/hermes-agent:latest";
    pull = "always";

    cmd = [ "gateway" "run" ];

    environment = {
      # Tell Hermes to use llama-server as the OpenAI-compatible backend
      "OPENAI_BASE_URL" = "http://llama-server:8080/v1";
      "OPENAI_API_KEY"  = "local";  # llama-server doesn't need a real key
      "API_SERVER_ENABLED" = "true";
      "API_SERVER_KEY" = "local-agent-key"; # Static key for dashboard auth
      "HERMES_DASHBOARD" = "1";
      "HERMES_DASHBOARD_INSECURE" = "1"; # only bound to localhost via ports below, so insecure mode is safe
    };

    volumes = [
      "/var/lib/hermes/data:/opt/data:rw"
    ];

    # Load secrets from a file on disk — never committed to the Nix store.
    # Create /storage/services/hermes/hermes.env and put any extra keys there.
    environmentFiles = [ "/var/lib/hermes/hermes.env" ];

    ports = [
      "8642:8642/tcp"  # Hermes API
      "9119:9119/tcp"  # Hermes dashboard / Web UI
    ];

    extraOptions = [
      "--network=hermes_net"
      "--network-alias=hermes"
    ];

    log-driver = "journald";
  };

  systemd.services."docker-hermes" = {
    serviceConfig.Restart = lib.mkOverride 90 "on-failure";
    after    = [
      "docker-network-hermes_net.service"
      "docker-llama-server.service"
    ];
    requires = [
      "docker-network-hermes_net.service"
      "docker-llama-server.service"
    ];
    partOf   = [ "docker-compose-hermes-root.target" ];
    wantedBy = [ "docker-compose-hermes-root.target" ];
  };

  # ── Isolated Docker network ───────────────────────────────────────────────
  systemd.services."docker-network-hermes_net" = {
    path = [ pkgs.docker ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "docker network rm -f hermes_net";
    };
    script = ''
      docker network inspect hermes_net || docker network create hermes_net
    '';
    partOf   = [ "docker-compose-hermes-root.target" ];
    wantedBy = [ "docker-compose-hermes-root.target" ];
  };

  # ── Root target ───────────────────────────────────────────────────────────
  systemd.targets."docker-compose-hermes-root" = {
    unitConfig.Description = "Hermes agent + llama.cpp inference stack";
    wantedBy = [ "multi-user.target" ];
  };

  # ── Persistent storage dirs ───────────────────────────────────────────────
  systemd.tmpfiles.rules = [
    "d /var/lib/hermes          0755 root root -"
    "d /var/lib/hermes/models   0755 root root -"
    "d /var/lib/hermes/data     0755 root root -"
    "f /var/lib/hermes/hermes.env 0600 root root -"
  ];
}
