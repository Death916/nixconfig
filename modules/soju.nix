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
      listen = [
        "irc+insecure://100.72.187.12:6667"
        "irc+insecure://100.72.187.12:6697"
        "irc+insecure://10.0.100.1:6697"
      ];
      enableMessageLogging = true;
    };
  };
}
