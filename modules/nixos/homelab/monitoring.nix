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
}