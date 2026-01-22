{ config, pkgs, unstablePkgs, ... }:

{
  users.users.death916.extraGroups = [ "home-assistant" ];

  services.home-assistant = {
    enable = true;
    package = unstablePkgs.home-assistant;
    extraComponents = [
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      "isal"
      "wled"
    ];
    extraPackages =
      python3Packages: with python3Packages; [
        pip
      ];

    config = {
      default_config = { };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
      };
    };
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        settings.allow_anonymous = true;
        address = "0.0.0.0";
        port = 1883;
      }
    ];
  };

  networking.firewall.allowedTCPPorts = [
    8123 # Home Assistant Web UI
    1883 # MQTT Broker
  ];

}
