{ pkgs, lib, config, ... }:

let
  apodScript = pkgs.writeShellScript "fetch-apod" ''
    set -euo pipefail
    CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/apod"
    mkdir -p "$CACHE_DIR"

    IMG_PATH="$CACHE_DIR/today.jpg"
    INFO_PATH="$CACHE_DIR/today.json"

    # Fetch today's metadata from NASA APOD API
    DATA=$(${pkgs.curl}/bin/curl -s --connect-timeout 10 --max-time 30 "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY&thumbs=true" || true)

    if [ -n "$DATA" ]; then
      IMG_URL=$(echo "$DATA" | ${pkgs.jq}/bin/jq -r '.hdurl // .url // .thumbnail_url // empty' 2>/dev/null || true)
      if [ -n "$IMG_URL" ] && [ "$IMG_URL" != "null" ]; then
        echo "$DATA" > "$INFO_PATH"
        ${pkgs.curl}/bin/curl -s --connect-timeout 10 --max-time 60 "$IMG_URL" -o "$IMG_PATH.tmp" && mv "$IMG_PATH.tmp" "$IMG_PATH"
      fi
    fi

    # Set wallpaper using awww
    if [ -f "$IMG_PATH" ]; then
      ${pkgs.awww}/bin/awww img "$IMG_PATH" --transition-type fade --transition-duration 2 || true
    fi
  '';
in
{
  # Enable Home Manager's built-in awww service
  services.awww.enable = true;

  # Service to fetch and apply NASA APOD
  systemd.user.services.apod-wallpaper = {
    Unit = {
      Description = "Fetch and apply NASA Astronomy Picture of the Day wallpaper";
      After = [ "awww.service" "network-online.target" ];
      Wants = [ "awww.service" "network-online.target" ];
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${apodScript}";
    };

    Install = {
      WantedBy = [ "graphical-session.target" "default.target" ];
    };
  };

  # Daily timer with persistence for laptop suspend catch-up
  systemd.user.timers.apod-wallpaper = {
    Unit = {
      Description = "Daily NASA APOD wallpaper update timer";
    };

    Timer = {
      OnCalendar = "*-*-* 06:00:00";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
