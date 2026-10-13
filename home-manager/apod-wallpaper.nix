{ pkgs, lib, config, ... }:

let
  apodScript = pkgs.writeShellScript "fetch-apod" ''
    set -euo pipefail

    API_KEY="''${NASA_API_KEY:-DEMO_KEY}"
    CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/apod"
    mkdir -p "$CACHE_DIR"

    # NASA migrated APOD off the legacy api.nasa.gov proxy (retired 2026-12-01).
    # The new WordPress endpoint returns a JSON array and needs a User-Agent.
    UA="apod-wallpaper/1.0"
    API_URL="https://science.nasa.gov/wp-json/wp/v2/apod-basic/?api_key=''${API_KEY}"

    # Fetch today's metadata. -f makes curl exit non-zero on HTTP >= 400, so a
    # 500/429 error body is never treated as valid data. Retries are deliberately
    # limited (3 total) with exponential backoff + jitter to avoid hammering the API.
    DATA=""
    MAX_ATTEMPTS=3
    delay=15
    attempt=1
    while [ "$attempt" -le "$MAX_ATTEMPTS" ]; do
      if DATA=$(${pkgs.curl}/bin/curl -fsS -A "$UA" --connect-timeout 10 --max-time 30 "$API_URL" 2>/dev/null); then
        break
      fi
      DATA=""
      if [ "$attempt" -lt "$MAX_ATTEMPTS" ]; then
        jitter=$((RANDOM % 10))
        echo "APOD: fetch attempt $attempt failed; retrying in $((delay + jitter))s" >&2
        sleep $((delay + jitter))
        delay=$((delay * 3))
      fi
      attempt=$((attempt + 1))
    done

    if [ -z "$DATA" ]; then
      echo "APOD: could not fetch valid data after $MAX_ATTEMPTS attempts; keeping current wallpaper" >&2
      exit 1
    fi

    # Normalize: the new endpoint wraps the entry in a JSON array
    NORM='if type == "array" then .[0] else . end'

    # Reject payloads that are API errors (e.g. rate limiting) despite a 2xx status
    if echo "$DATA" | ${pkgs.jq}/bin/jq -e '.code? // empty' >/dev/null 2>&1; then
      echo "APOD: API returned an error payload: $(echo "$DATA" | ${pkgs.jq}/bin/jq -r '.msg? // ""')" >&2
      exit 1
    fi

    # awww caches images by path, so a fixed "today.jpg" would keep serving the
    # stale bitmap when the contents change. Use a date-stamped path instead.
    APOD_DATE=$(echo "$DATA" | ${pkgs.jq}/bin/jq -r "''${NORM} | .date // empty")
    [ -z "$APOD_DATE" ] && APOD_DATE=$(${pkgs.coreutils}/bin/date +%F)
    IMG_PATH="$CACHE_DIR/apod-$APOD_DATE.jpg"
    INFO_PATH="$CACHE_DIR/apod-$APOD_DATE.json"

    MEDIA_TYPE=$(echo "$DATA" | ${pkgs.jq}/bin/jq -r "''${NORM} | .media_type // empty")
    # In the new API .hdurl is the direct image asset; .url is the article
    # permalink (HTML), so only fall back to .url if it is an image file.
    IMG_URL=$(echo "$DATA" | ${pkgs.jq}/bin/jq -r "''${NORM} | .hdurl // empty")
    if [ -z "$IMG_URL" ] || [ "$IMG_URL" = "null" ]; then
      CASE_URL=$(echo "$DATA" | ${pkgs.jq}/bin/jq -r "''${NORM} | .url // empty")
      case "$CASE_URL" in
        *.jpg|*.jpeg|*.png|*.gif|*.webp) IMG_URL="$CASE_URL" ;;
      esac
    fi

    # The API's hdurl ships with crop=faces,focalpoint, which makes NASA's CDN
    # return a tiny (~960px) thumbnail. Drop those params and request a full 4K
    # render ourselves. (>~4096 makes the CDN fall back to the tiny default.)
    case "$IMG_URL" in
      *assets.science.nasa.gov/dynamicimage*)
        IMG_URL="''${IMG_URL%%\?*}?w=3840&fit=clip" ;;
    esac

    # Some days have no downloadable image (e.g. videos); skip cleanly
    if [ "$MEDIA_TYPE" != "image" ] || [ -z "$IMG_URL" ] || [ "$IMG_URL" = "null" ]; then
      echo "APOD: today's entry is not a downloadable image (media_type=$MEDIA_TYPE); keeping current wallpaper" >&2
      exit 0
    fi

    echo "$DATA" > "$INFO_PATH.tmp"
    ${pkgs.curl}/bin/curl -fsS -A "$UA" --connect-timeout 10 --max-time 60 "$IMG_URL" -o "$IMG_PATH.tmp"
    mv "$INFO_PATH.tmp" "$INFO_PATH"
    mv "$IMG_PATH.tmp" "$IMG_PATH"

    for old in "$CACHE_DIR"/apod-*.jpg "$CACHE_DIR"/apod-*.json; do
      [ -e "$old" ] || continue
      [ "$old" = "$IMG_PATH" ] || [ "$old" = "$INFO_PATH" ] || rm -f "$old"
    done

    # Set wallpaper using awww
    ${pkgs.awww}/bin/awww img "$IMG_PATH" --transition-type fade --transition-duration 2 \
      || echo "APOD: failed to set wallpaper (is a Wayland session running?)" >&2
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
      # Optional; falls back to DEMO_KEY if missing. Must contain NASA_API_KEY=...
      # and be readable by the user (chmod 600). Kept outside the repo so the
      # key is never committed.
      EnvironmentFile = [ "-${config.home.homeDirectory}/.config/nasa.env" ];
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
