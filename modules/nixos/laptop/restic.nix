{ config, pkgs, ... }:

{

  services.restic.backups.laptop = {
    user = "root";
    initialize = true;
    passwordFile = "/etc/nixos/secrets/restic-auth";
    repository = "s3:d8j2.or.idrivee2-38.com/backups";
    environmentFile = "/etc/nixos/secrets/restic.env";
    paths = [
      "/home/"
      "/root"
      "/var/lib/"
      # "/var/log/"
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
      OnCalendar = "03:00,09:00,15:00,21:00";
      Persistent = true;
      RandomizedDelaySec = "15m";
    };
  };

  systemd.services."restic-backups-laptop".serviceConfig = {
    Nice = 19;
    IOSchedulingClass = "idle";
  };

}
