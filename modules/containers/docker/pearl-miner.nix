{ pkgs, ... }:

let
  user = "death916";
  cryptoDir = "/home/${user}/crypto";
  docker = "${pkgs.docker}/bin/docker";
in
{
  systemd.services.pearl-miner-start = {
    description = "Start Pearl Miner";
    serviceConfig = {
      Type = "oneshot";
      User = user;
      WorkingDirectory = cryptoDir;
      ExecStart = "${docker} compose up -d";
    };
  };

  systemd.services.pearl-miner-stop = {
    description = "Stop Pearl Miner";
    serviceConfig = {
      Type = "oneshot";
      User = user;
      WorkingDirectory = cryptoDir;
      ExecStart = "${docker} compose down";
    };
  };

  systemd.timers.pearl-miner-start = {
    description = "Timer to start Pearl Miner (Off-Peak)";
    timerConfig = {
      OnCalendar = [ "Mon..Fri 20:02:00" "Sat,Sun 00:00:00" ];
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };

  systemd.timers.pearl-miner-stop = {
    description = "Timer to stop Pearl Miner during Weekday Peak (5:00 PM)";
    timerConfig = {
      OnCalendar = "Mon..Fri 17:00:00";
      Persistent = true;
    };
    wantedBy = [ "timers.target" ];
  };
}
