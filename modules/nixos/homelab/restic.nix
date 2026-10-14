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
      OnCalendar = "01,07,13,19:30:00";
      Persistent = true;
      RandomizedDelaySec = "10m";
    };
  };

  systemd.services."restic-backups-homelab".serviceConfig = {
    Nice = 19;
    IOSchedulingClass = "idle";
  };

}
