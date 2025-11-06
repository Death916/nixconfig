{ config, pkgs, ... }:

{

  services.restic.backups.laptop = {
         user = "death916";
         initialize = true;

         repository = "s3:backups.d8j2.or.idrivee2-38.com";
         environmentFile = "/etc/nixos/secrets/restic.env";
         paths = [
           "/home/"
           "/root"
           "/var/lib/"
           "/var/log/"
           "/etc/"

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
