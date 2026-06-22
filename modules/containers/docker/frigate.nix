{
  config,
  pkgs,
  lib,
  ...
}:

{
  virtualisation.oci-containers.containers.frigate = {
    image = "ghcr.io/blakeblackshear/frigate:stable";
    privileged = true;
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/var/lib/frigate/config:/config"
      "/var/lib/frigate/storage:/media/frigate"
      "type=tmpfs,target=/tmp/cache,tmpfs-size=1000000000"
    ];
    ports = [
      "8971:8971"
      "5000:5000"
      "8554:8554"
      "8555:8555/tcp"
      "8555:8555/udp"
    ];
    extraOptions = [
      "--shm-size=64m"
      "--device=/dev/dri/renderD128:/dev/dri/renderD128"
    ];
  };

  # Open the default Frigate Web UI and streaming ports
  networking.firewall.allowedTCPPorts = [
    8971 # Web UI (Authenticated)
    5000 # Web UI (Unauthenticated)
    8554 # RTSP
    8555 # WebRTC
  ];
  networking.firewall.allowedUDPPorts = [
    8555 # WebRTC
  ];

}
