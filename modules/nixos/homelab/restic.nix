{ config, pkgs, ... }:

{

  services.restic.backups.homelab = {
         user = "root";
         initialize = true;
         passwordFile = "/etc/nixos/secrets/restic-auth";
         repository = "s3:d8j2.or.idrivee2-38.com/backups";
         environmentFile = "/etc/nixos/secrets/restic.env";
         paths = [
           "/home/"
           "/root"
           "/var/lib/"
           "/var/log/"
           "/etc/"
           "/storage/"

            ];
         pruneOpts = [
           "--keep-hourly 48"
           "--keep-daily 7"
           "--keep-weekly 4"
           "--keep-monthly 12"
           "--keep-yearly 5"
         ];
         extraBackupArgs = [
           "--verbose"
           "--exclude-caches"
         ];
         timerConfig = {
           OnCalendar = "daily";
           Persistent = true;
         };
       };

}
