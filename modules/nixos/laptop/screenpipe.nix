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
      SCREENPIPE_USE_NPU_OCR = "1";
      LEMONADE_VISION_MODEL = "qwen3vl-it-4b-FLM";
      LEMONADE_API_URL = "http://127.0.0.1:13305/v1/chat/completions";
      LEMONADE_TIMEOUT_SECS = "90";
      LEMONADE_CTX_SIZE = "4096";
    };

    serviceConfig = {
      # Runs natively, storing data in the default SSD path (~/.local/share/screenpipe/)
      # Disables audio for lightweight background OCR
      ExecStart = "${screenpipe-pkg}/bin/screenpipe record --disable-audio --listen-on-lan --ignored-windows \"cosmic-launcher\" --ignored-windows \"cosmic-app-library\" --ignored-windows \"cosmic-app-list\" --ignored-windows \"cosmic-applet\" --ignored-windows \"cosmic-panel\" --ignored-windows \"cosmic-notifications\" --ignored-windows \"cosmic-osd\" --ignored-windows \"cosmic-workspaces\"";
      Restart = "always";
      RestartSec = 5;
    };
  };
}
