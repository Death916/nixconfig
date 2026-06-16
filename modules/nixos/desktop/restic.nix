{ config, pkgs, ... }:

{

  services.restic.backups.death-pc = {
    user = "root";
    initialize = true;
    passwordFile = "/etc/nixos/secrets/restic-auth";
    repository = "s3:d8j2.or.idrivee2-38.com/backups";
    environmentFile = "/etc/nixos/secrets/restic.env";
    paths = [
      "/home/"
      "/root"
      "/var/lib/"
      "/etc/"
    ];
    exclude = [
      "/home/death916/.local/share/*"
      "/home/death916/Downloads"
      "*/.cache/*"
    ];

    extraBackupArgs = [
      "--verbose"
      "--exclude-caches"
    ];
    timerConfig = {
      OnCalendar = "04:30,10:30,16:30,22:30";
      Persistent = true;
      RandomizedDelaySec = "15m";
    };
  };

  systemd.services."restic-backups-death-pc".serviceConfig = {
    Nice = 19;
    IOSchedulingClass = "idle";
  };

}
