{ config, pkgs, ... }:

{
  services.umami = {
    enable = true;
    createPostgresqlDatabase = true;
    settings = {
      PORT = "3010";
      APP_SECRET_FILE = "/etc/nixos/secrets/umami.env";
      DISABLE_TELEMETRY = true;
    };
  };
}
