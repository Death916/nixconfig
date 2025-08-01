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
      hostName = "oracle";
      listen = [ "irc+insecure://0.0.0.0" ];

    };
  };
}
