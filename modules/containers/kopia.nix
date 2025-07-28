
{ config, pkgs, lib, ... }:

{
  options.services.kopia = {
    enable = lib.mkEnableOption "Kopia backup service";
  };

  config = lib.mkIf config.services.kopia.enable {
    virtualisation.oci-containers.containers.kopia = {
      image = "kopia/kopia:latest";
      hostname = "Hostname";
      containerName = "Kopia";
      autoStart = true;
      restart = "unless-stopped";
      networkMode = "bridge";
      ports = [ "51515:51515" ];
      environment = {
        KOPIA_PASSWORD = "REDACTED";
        USER = "death916";
        TZ = "America/Los_Angeles";
      };
      volumes = [
        "/home/death916/certs:/certs"
        "/home/death916/docker/volumes/kopia:/app/config"
        "/home/death916/docker/volumes/kopia:/app/cache"
        "/home/death916/docker/volumes/kopia:/app/logs"
        "/:/data:ro"
        "/tmp:/tmp:shared"
      ];
      cmd = [
        "server"
        "start"
        "--disable-csrf-token-checks"
        "--tls-cert-file=/certs/pimox.bandicoot-skate.ts.net.crt"
        "--tls-key-file=/certs/pimox.bandicoot-skate.ts.net.key"
        "--address=0.0.0.0:51515"
        "--server-username=death916"
        "--server-password=REDACTED"
      ];
    };
  };
}
