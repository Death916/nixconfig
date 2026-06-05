{
  config,
  pkgs,
  unstablePkgs,
  ...
}:

{
  services.frigate = {
    enable = true;
    package = unstablePkgs.frigate;
    hostname = "homelab";

    settings = {
      mqtt = {
        enabled = true;
        host = "127.0.0.1";
        port = 1883;
      };

      # Basic CPU detector for AMD Ryzen
      detectors.cpu1 = {
        type = "cpu";
      };

      cameras = {
        # Template camera configuration.
        # Update 'path' with your RTSP stream and set 'enabled: true' to start detection.
        example_camera = {
          ffmpeg.inputs = [
            {
              path = "rtsp://admin:password@192.168.1.10:554/live";
              roles = [
                "detect"
                "record"
              ];
            }
          ];
          detect = {
            enabled = false;
          };
        };
      };

      # Recording and snapshot storage (default locations)
      record = {
        enabled = false;
        retain = {
          days = 0;
          mode = "all";
        };
      };

      snapshots = {
        enabled = false;
      };
    };
  };

  # Open the default Frigate Web UI port
  networking.firewall.allowedTCPPorts = [ 5000 ];

  # Frigate needs access to hardware for potential acceleration and storage
  users.users.frigate.extraGroups = [
    "video"
    "render"
  ];

  # Ensure the storage directory exists with correct permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/frigate 0750 frigate frigate -"
  ];
}
