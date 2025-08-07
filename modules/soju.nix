{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    services.soju = {

      enable = true;
      hostName = "orac";
      listen = [ "irc+insecure://0.0.0.0:6697" ];
      enableMessageLogging = true;
    };
  };
}
