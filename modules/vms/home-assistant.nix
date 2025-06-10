# ./modules/vms/home-assistant.nix
{ config, lib, pkgs, ... }:

with lib;

{
  options.services.homeAssistantVM = {
    enable = mkEnableOption "Home Assistant VM specific configurations";
  };
  config = mkIf config.services.homeAssistantVM.enable {
    networking.firewall.allowedTCPPorts = [
      8123 # Home Assistant Web UI default port
    ];

    environment.systemPackages = with pkgs; [
      wget # For downloading the Home Assistant OS image
      xz   # For decompressing the Home Assistant OS image
    ];
  };
}

