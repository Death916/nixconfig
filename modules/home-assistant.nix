# /home/death916/nixconfig/modules/home-assistant.nix
{ config, pkgs, lib, unstablePkgsHA, ... }: # Added unstablePkgsHA

{
  services.home-assistant = {
    enable = true;
    package = unstablePkgsHA.home-assistant; # Use HA package from unstable

    extraComponents = [
      "esphome"
      "met"
      "radio_browser"
      "wled"
      "tplink"
      "onvif"
    ];

    extraPackages = python3Packages: with python3Packages; [
      aiogithubapi # Added dependency for HACS
      python-kasa
      pychromecast
      pytapo      
    ];

    config = {
      default_config = {};
      homeassistant = {
        name = "Homelab HA (Unstable)";
        
        time_zone = "America/Los_Angeles";
      };
      # Add other integrations as needed
    };
  };

  # Firewall rule for Home Assistant
  networking.firewall = {
    allowedTCPPorts = [ 8123 ];
    allowedUDPPorts = [ 
      5353  # mDNS/Bonjour discovery
      1900  # SSDP/UPnP discovery
      1901  # UPnP
      3702  # WS-Discovery (ONVIF specific)
    ];
  };

  # Ensure the `hass` user has access to necessary devices (e.g., Zigbee/Z-Wave dongles)
  users.users.hass.extraGroups = lib.mkIf (config.services.home-assistant.enable) [
    "dialout" # Common group for serial devices
    # Add other groups if needed
  ];

}
