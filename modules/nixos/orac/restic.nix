{ config, pkgs, ... }:

{

  # Dump JuiceFS PostgreSQL metadata before backup
  systemd.services."juicefs-metadata-dump" = {
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      EnvironmentFile = "/etc/nixos/secrets/juicefs.env";
    };
    script = ''
      ${pkgs.docker}/bin/docker exec postgres-for-juicefs \
        pg_dump -U death916 juicefs | ${pkgs.gzip}/bin/gzip > /root/juicefs-metadata.sql.gz
    '';
  };

  systemd.timers."juicefs-metadata-dump" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:10";
      Persistent = true;
    };
  };

  services.restic.backups.orac = {
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
      "/mnt/myjfs/"
    ];

    exclude = [
      "/mnt/*/.accesslog"
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
      OnCalendar = "*:20";
      Persistent = true;
      RandomizedDelaySec = "20m";
    };
  };

}
