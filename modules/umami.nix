{ config, pkgs, ... }:

{
  services.umami = {
    enable = true;
    port = 3010;
    database.url = "postgresql://umami@/umami?host=/run/postgresql";
    secretFile = "/etc/nixos/secrets/umami.env";
    settings = {
      DISABLE_TELEMETRY = "1";
    };
  };
}
