{ config, ... }:
{
  # Restic secrets / passwords
  sops.secrets = {
  };

  services.restic.backups = {
    laptop-backups = {
      initialize = true;
      paths = [
        "/etc"
        "/srv"
        "/var/log"
        "/home/"
        "/var/lib/"
        "/root/"
        "/storage"
      ];
      repository = "s3:s3.us-west-000.backblazeb2.com";
      environmentFile = config.sops.secrets."restic/B2-Backblaze/environment".path;
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
      extraBackupArgs = [
        "--verbose"
        "--exclude-caches"
      ];
      pruneOpts = [
        "--keep-weekly 4"
        "--keep-monthly 6"
        "--keep-yearly 3"
      ];
    };

    home-folder = {
      initialize = true;
      paths = [ "/home/death916/Desktop" ];
      repository = "b2:nuc-server-B2-Docker:/";
      environmentFile = config.sops.secrets."restic/B2-Docker/environment".path;
      passwordFile = config.sops.secrets."restic/B2-Docker/password".path;
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
      extraBackupArgs = [
        "--verbose"
        "--exclude-caches"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 8"
        "--keep-monthly 6"
        "--keep-yearly 1"
      ];
    };

    B2-Photos = {
      initialize = true;
      paths = [ "/Storage/Media/Pictures" ];
      repository = "b2:nuc-server-B2-Photos:/";
      environmentFile = config.sops.secrets."restic/B2-Photos/environment".path;
      passwordFile = config.sops.secrets."restic/B2-Photos/password".path;
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
      };
      extraBackupArgs = [
        "--verbose"
        "--exclude-caches"
      ];
      pruneOpts = [
        "--keep-weekly 8"
        "--keep-monthly 12"
        "--keep-yearly 5"
      ];
    };

  };
}
