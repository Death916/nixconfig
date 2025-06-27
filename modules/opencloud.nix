# opencloud.nix
{ config, pkgs, ... }: # This defines a NixOS module that takes config, pkgs, etc. as arguments [2]

{
  services.opencloud = {
    enable = true;
    environment = {
      OC_INSECURE = "true";
      OC_BASIC_AUTH_ENABLE = "true";
      OC_BASIC_AUTH_USERNAME = "death916"; # Replace with your desired username
      OC_BASIC_AUTH_PASSWORD = "(builtins.readFile /etc/nixos/secrets/opencloud"; # Replace with your desired password
      OC_LOG_LEVEL = "info";
    };
    listenAddress = "0.0.0.0";
    port = 9000;
  };
}

