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

    exclude = [
      "*/.cache/"
    ];

    extraBackupArgs = [
      "--verbose"
      "--exclude-caches"
    ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      RandomizedDelaySec = "20m";
    };
  };

}
