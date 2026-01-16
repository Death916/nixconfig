{ config, pkgs, ... }:
{
  # grafana configuration
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3050;
        enforce_domain = false;
        enable_gzip = true;
        # domain = "orac";
      };
    };
  };
  services.prometheus = {
    enable = true;
    port = 9001;
    scrapeConfigs = [
      {
        job_name = "orac";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
          }
        ];
      }
      {
        job_name = "homelab";
        static_configs = [
          {
            targets = [ "100.65.36.116:9002" ];
          }
        ];
      }
      {
        job_name = "crowdsec";
        static_configs = [
          {
            targets = [ "127.0.0.1:6060" ];
          }
        ];
      }
    ];
    exporters = {
      node = {

        enable = true;
        port = 9002;
        # For the list of available collectors, run, depending on your install:
        # - Flake-based: nix run nixpkgs#prometheus-node-exporter -- --help
        # - Classic: nix-shell -p prometheus-node-exporter --run "node_exporter --help"
        enabledCollectors = [
          "ethtool"
          "softirqs"
          "systemd"
          "tcpstat"
          "wifi"
          "sysctl"
          "processes"
          "cgroups"
        ];
        # You can pass extra options to the exporter using `extraFlags`, e.g.
        # to configure collectors or disable those enabled by default.
        # Enabling a collector is also possible using "--collector.[name]",
        # but is otherwise equivalent to using `enabledCollectors` above.
        extraFlags = [
          "--collector.ntp.protocol-version=4"
          "--no-collector.mdadm"
          "--collector.systemd.unit-include=.*"
        ];
      };
    };
  };
}
