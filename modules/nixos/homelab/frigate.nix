{
  config,
  pkgs,
  lib,
  unstablePkgs,
  ...
}:

{
  services.frigate = {
    enable = true;
    checkConfig = false; # Disable build-time check as it fails to resolve runtime env vars
    package = unstablePkgs.frigate;
    hostname = "homelab";

    settings = {
      database.path = "/storage/services/frigate/frigate.db";
      mqtt = {
        enabled = true;
        host = "127.0.0.1";
        port = 1883;
      };

      # Use OpenVINO for high-performance detection on the CPU.
      # This is much faster than the default 'cpu' detector on Ryzen.
      detectors.ov = {
        type = "openvino";
        device = "CPU";
      };

      # Face recognition is disabled for now to save RAM
      faces.enabled = false;

      cameras = {
        kitchen_cam = {
          ffmpeg.inputs = [
            {
              path = "rtsp://{FRIGATE_CAMERA_USER}:{FRIGATE_CAMERA_PASSWORD}@192.168.0.188:554/stream1";
              roles = [ "record" ];
            }
            {
              path = "rtsp://{FRIGATE_CAMERA_USER}:{FRIGATE_CAMERA_PASSWORD}@192.168.0.188:554/stream2";
              roles = [ "detect" ];
            }
          ];
          objects.track = [ "person" ]; # Focus on people to avoid car spam
        };
        living_room_cam = {
          ffmpeg.inputs = [
            {
              path = "rtsp://{FRIGATE_CAMERA_USER}:{FRIGATE_CAMERA_PASSWORD}@192.168.0.157:554/stream1";
              roles = [ "record" ];
            }
            {
              path = "rtsp://{FRIGATE_CAMERA_USER}:{FRIGATE_CAMERA_PASSWORD}@192.168.0.157:554/stream2";
              roles = [ "detect" ];
            }
          ];
          objects.track = [ "person" ];
        };
      };

      # Recording and snapshot storage (default locations)
      record = {
        enabled = true;
        retain = {
          days = 3;
          mode = "all";
        };
      };

      snapshots = {
        enabled = true;
      };
    };
  };

  # Load camera credentials from a secrets file
  systemd.services.frigate.serviceConfig.EnvironmentFile = "/etc/nixos/secrets/frigate.env";

  # Ensure Frigate waits for the storage mount
  systemd.services.frigate.unitConfig.RequiresMountsFor = [ "/storage" "/var/lib/frigate" ];

  # Use a bind mount instead of a symlink to move storage to the HDD.
  # This makes it appear as a real directory on the other drive for 'df' and 'du'.
  fileSystems."/var/lib/frigate" = {
    device = "/storage/services/frigate";
    fsType = "none";
    options = [ "bind" ];
  };

  # Force Nginx to listen on all interfaces for the Frigate Web UI
  # The NixOS module defaults to 127.0.0.1:5000 for internal use,
  # but we want it accessible externally.
  services.nginx.virtualHosts."homelab" = {
    listen = lib.mkForce [
      { addr = "0.0.0.0"; port = 5000; }
      { addr = "0.0.0.0"; port = 8971; }
    ];
  };

  # Open the default Frigate Web UI and streaming ports
  networking.firewall.allowedTCPPorts = [
    5000 # Web UI (Unauthenticated/Legacy)
    8971 # Web UI (Authenticated - Frigate v0.13+)
    8554 # RTSP
    8555 # WebRTC
  ];
  networking.firewall.allowedUDPPorts = [
    8555 # WebRTC
  ];

  # Frigate needs access to hardware for potential acceleration and storage
  users.users.frigate.extraGroups = [
    "video"
    "render"
  ];

  # Ensure the storage directory exists with correct permissions
  systemd.tmpfiles.rules = [
    "d /storage/services/frigate 0750 frigate frigate -"
  ];
}
