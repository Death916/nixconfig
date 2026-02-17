{ config, pkgs, lib, ... }:

{
  virtualisation.oci-containers.containers = {
    navidrome = {
      image = "deluan/navidrome:0.60.3";
      user = "1000:1000";
      volumes = [
        "/var/lib/navidrome:/data"
        "/media/storage/media/music:/music:ro"
      ];
      ports = [ "4533:4533" ];
      environment = {
        ND_MUSICFOLDER = "/music";
        ND_DATAFOLDER = "/data";
        ND_CACHEFOLDER = "/data/cache";
      };
    };
  };
}
