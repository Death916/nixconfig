{ config, pkgs, ... }:

{
  # Soju IRC Bouncer Service
  services.soju = {
    enable = true;
    hostName = "irc.example.com"; # IMPORTANT: Replace with your actual hostname
    listen = "0.0.0.0:6697"; # Listens on all interfaces, use "127.0.0.1:6697" for local only
    extraConfig = ''
      db postgres "host=/run/postgresql dbname=soju"
    '';
  };

  # This will create the necessary database and user for soju.
  # It assumes you have `services.postgresql.enable = true` elsewhere in your config.
  services.postgresql = {
    ensureDatabases = [ "soju" ];
    ensureUsers = [
      {
        name = "soju";
        ensureDBOwnership = true;
      }
    ];
  };
}
