{ config, pkgs, ... }:

{
  systemd.services.obsidian-rclone = {
    description = "Obsidian rclone bisync";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "death916";
      Group = "users";
      ExecStart = "${pkgs.rclone}/bin/rclone bisync /home/death916/notes gdrive-notes:ObsidianVault --verbose";
    };
  };

  systemd.timers.obsidian-rclone = {
    description = "Timer for Obsidian rclone bisync";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "10m";
      Unit = "obsidian-rclone.service";
    };
  };
}
