{ config, pkgs, ... }:

{
  services.umami = {
    enable = true;
    createPostgresqlDatabase = true;
    settings = {
      PORT = "3010";
      DISABLE_TELEMETRY = "1";
    };
  };
}
