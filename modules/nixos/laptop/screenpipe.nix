# modules/nixos/laptop/screenpipe.nix
{ config, pkgs, ... }:

let
  screenpipe-pkg = pkgs.callPackage ../../../pkgs/screenpipe { };
in
{
  # 1. Add the custom screenpipe package
  environment.systemPackages = [ screenpipe-pkg ];

  # 2. Declarative systemd user service (starts automatically inside the graphical session)
  systemd.user.services.screenpipe = {
    description = "Screenpipe local context recording daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    path = [ pkgs.tesseract pkgs.ffmpeg ];

    environment = {
      SCREENPIPE_API_KEY = "local-recall-key";
    };

    serviceConfig = {
      # Runs natively, storing data in the default SSD path (~/.local/share/screenpipe/)
      # Disables audio for lightweight background OCR
      ExecStart = "${screenpipe-pkg}/bin/screenpipe record --disable-audio --listen-on-lan";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
