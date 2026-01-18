{ config, pkgs, ... }:
{
  services.prometheus.exporters.node = {
    enable = true;
    port = 9002;
    enabledCollectors = [
      "systemd"
      "tcpstat"
      "wifi"
      "ethtool"
      "softirqs"
      "processes"
    ];
    extraFlags = [
      "--collector.systemd.unit-include=.*"
    ];
    openFirewall = true;
  };
  services.prometheus.exporters.process = {
    enable = true;
    port = 9256;
    openFirewall = true;
    settings.process_names = [
      {
        name = "{{.Comm}}";
        cmdline = [ ".+" ];
      }
    ];
  };
}