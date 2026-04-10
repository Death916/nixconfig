{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.services.forgejo;
  srv = cfg.settings.server;
in
{
  services.forgejo = {
    enable = true;
    database = {
      type = "postgres";
      user = "forgejo";
      name = "forgejo";
      socket = "/run/postgresql";
    };

    lfs.enable = true;

    settings = {
      server = {
        HTTP_ADDR = "0.0.0.0";
        DOMAIN = "git.death916.xyz";
        ROOT_URL = "https://${srv.DOMAIN}/";
        HTTP_PORT = 3051;
        PROTOCOL = "http";
      };
      service.DISABLE_REGISTRATION = true;

      actions = {
        ENABLED = true;
        DEFAULT_ACTIONS_URL = "github";
      };

      mailer = {
        ENABLED = true;
        SMTP_ADDR = "mail.smtp2go.com";
        FROM = "noreply@${srv.DOMAIN}";
        USER = "noreply@${srv.DOMAIN}";
        SMTP_PORT = 465;
        PROTOCOL = "smtp+starttls";
      };

      storage = {
        STORAGE_TYPE = "minio";
        MINIO_ENDPOINT = "d8j2.or.idrivee2-38.com";
        MINIO_BUCKET = "forgejo-storage";
        MINIO_LOCATION = "d8j2";
        MINIO_USE_SSL = true;
      };
    };

    secrets = {
      mailer.PASSWD = "/etc/nixos/secrets/forgejo-mailer-password";
      storage.MINIO_ACCESS_KEY_ID = "/etc/nixos/secrets/forgejo-s3-access-key-id";
      storage.MINIO_SECRET_ACCESS_KEY = "/etc/nixos/secrets/forgejo-s3-secret-access-key";
    };
  };

  networking.firewall.allowedTCPPorts = [ 3051 ];
}
