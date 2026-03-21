{
  config,
  pkgs,
  unstablePkgs,
  ...
}:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;
        modules-left = [
          "tray"
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [
          "clock"
          "mpris"
        ];
        modules-right = [
          "custom/wttrbar"
          "pulseaudio"
          "network"
          "cpu"
          "memory"
          "battery"
        ];

        "custom/wttrbar" = {
          "format" = "{text}°";
          "return-type" = "json";
          "exec" = "wttrbar --location Sacramento --fahrenheit";
          "interval" = 3600;
        };

        "tray" = {
          "spacing" = 10;
        };

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "󰎤";
            "2" = "󰎧";
            "3" = "󰎪";
            "4" = "󰎭";
            "5" = "󰎱";
            "6" = "󰎳";
            "7" = "󰎶";
            "8" = "󰎹";
            "9" = "󰎼";
            "10" = "󰎿";
            "active" = "";
            "default" = "";
          };
        };

        "hyprland/window" = {
          max-length = 50;
        };

        "clock" = {
          format = "{:%Y-%m-%d %H:%M:%S}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        "mpris" = {
          format = "{player_icon} {title} - {artist}";
          format-paused = "⏸ {title} - {artist}";
          format-stopped = "";
          unknown-display = "mpris";
          max-length = 50;
          player-icons = {
            default = "▶";
            spotify = "";
            firefox = "";
            vlc = "󰕼";
            tauon = "";
            kdeconnect = "";
          };
          status-icons = {
            paused = "⏸";
            playing = "▶";
            stopped = "⏹";
          };
          on-click-left = "playerctl play-pause";
          on-click-right = "playerctl next";
          on-click-middle = "playerctl previous";
          on-scroll-up = "playerctl seek 5";
          on-scroll-down = "playerctl seek -5";
          tooltip-format = "{title} - {artist}";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = " Muted";
          on-click = "pavucontrol";
          format-icons = {
            "default" = [
              ""
              ""
              ""
            ];
          };
        };

        "network" = {
          format-wifi = " {essid} ({signalStrength}%) ";
          format-ethernet = " {ifname}";
          format-disconnected = "⚠ Disconnected";
        };

        "cpu" = {
          format = " {usage}%";
        };

        "memory" = {
          format = " {}%";
        };

        "battery" = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-alt = "{time} {icon}";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
        };
      };
    };
    style = ''
      #workspaces {
        font-size: 18px;
      }

      #workspaces button {
        padding: 0 8px;
      }
    '';
  };

  home.packages = with pkgs; [
    waybar
    playerctl
    unstablePkgs.wttrbar
  ];
}
