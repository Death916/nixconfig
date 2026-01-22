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
      OnCalendar = "*:40";
      Persistent = true;
      RandomizedDelaySec = "10m";
    };
  };

}
