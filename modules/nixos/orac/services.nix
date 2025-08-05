{
  config,
  pkgs,
  ...
}:
{

  virtualisation.docker.enable = true;

  systemd.services.kopia-backup = {
    description = "Kopia backup service for NixOS server";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "/usr/local/bin/nixos-kopia-backup.sh";
      path = with pkgs; [
        coreutils
        kopia
      ];
    };
  };

  systemd.timers.kopia-backup = {
    description = "Daily Kopia backup timer";
    wantedBy = [ "timers.target" ];
    partOf = [ "kopia-backup.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
      Unit = "kopia-backup.service";
    };
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 10";
    flake = "/home/death916/nixconfig/";
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    tailscale
    rsync
    multipath-tools
    btop
    wget
    unzip
    kopia
    manix
  ];
}
