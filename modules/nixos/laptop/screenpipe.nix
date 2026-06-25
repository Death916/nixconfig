# modules/nixos/laptop/screenpipe.nix
{ config, pkgs, ... }:

{
  # 1. Add the native screen-pipe package from NixOS 26.05
  environment.systemPackages = [ pkgs.screen-pipe ];

  # 2. Declarative systemd user service (starts automatically inside the graphical session)
  systemd.user.services.screenpipe = {
    description = "Screenpipe local context recording daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    serviceConfig = {
      # Runs natively, storing data in the default SSD path (~/.local/share/screenpipe/)
      # Disables audio for lightweight background OCR
      ExecStart = "${pkgs.screen-pipe}/bin/screenpipe --use-local-ocr --disable-audio --fps 1";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
