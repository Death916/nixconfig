{
  pkgs,
  config,
  ...
}: {
  

  

  services.restic.backups = {
    remotebackup = {
      exclude = [
        *cache
      ]
      initialize = true;
      paths = [ # what to backup
        "/etc"
        "/srv"
        "/var/log"
        "/home"
        "/var/lib"
        "/root"
        "/storage"
      ];
      passwordFile = "/etc/nixos/secrets/restic-password"; # encryption
      repository = "s3:s3.idrivee2.com/your-bucket-name"; # where to store it
      environment = {
        AWS_ACCESS_KEY_ID = "/etc/nixos/secrets/restic-s3-access-key-id";
        AWS_SECRET_ACCESS_KEY = "/etc/nixos/secrets/restic-s3-secret-access-key";
      };
      timerConfig = { # when to backup
        OnCalendar = "00:05";
        RandomizedDelaySec = "5h";
      };
    };
  };
}
