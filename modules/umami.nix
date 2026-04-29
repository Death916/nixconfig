{ config, pkgs, ... }:

{
  services.umami = {
    enable = true;
    createPostgresqlDatabase = true;
    settings = {
      HOSTNAME = "0.0.0.0"
      PORT = 3010;
      APP_SECRET_FILE = "/etc/nixos/secrets/umami.env";
      DISABLE_TELEMETRY = true;
    };
  };
}
