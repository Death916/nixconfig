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
      hostName = "0.0.0.0";
      listen = [ "irc+insecure://0.0.0.0:6667" ];
      enableMessageLogging = true;
    };
  };
}
