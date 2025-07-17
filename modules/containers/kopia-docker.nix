
{ config, lib, ... }:

with lib;

let
   Define a shorthand for the module's options
     cfg = config.services.kopia-docker;
   in
   {
     options.services.kopia-docker.enable = mkEnableOption (mdDoc "Kopia backup server (running in a container)");
  
     config = mkIf cfg.enable {
       virtualisation.oci-containers.containers.kopia = {
         image = "kopia/kopia:latest";
         extraOptions = [ "--network=host" ];
         volumes = [
           "/etc:/etc:ro"
           "/srv:/srv:ro"
           "/var/log:/var/log:ro"
           "/home:/home:ro"
           "/var/lib:/var/lib:ro"
           "/root:/root:ro"
           "/storage:/storage:ro"
           "/storage/services/kopia:/app/config"
           "/storage/services/kopia/cache:/app/cache"
           "/storage/services/kopia/logs:/app/logs"
           "/etc/nixos/secrets/kopia_password:/run/secrets/kopia-control-password:ro"
         ];
         entrypoint = [
           "kopia"
           "server"
           "start"
           "--insecure"
           "--address=0.0.0.0:51515"
           "--server-control-username=homelab"
           "--server-control-password-from-file=/run/secrets/kopia-control-password"
         ];
       };
     };
   }
