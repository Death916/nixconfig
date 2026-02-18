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
    # style = '' # Managed by stylix
    #   @define-color rosewater #f5e0dc;
    #   @define-color flamingo #f2cdcd;
    #   @define-color pink #f5c2e7;
    #   @define-color mauve #cba6f7;
    #   @define-color red #f38ba8;
    #   @define-color maroon #eba0ac;
    #   @define-color peach #fab387;
    #   @define-color yellow #f9e2af;
    #   @define-color green #a6e3a1;
    #   @define-color teal #94e2d5;
    #   @define-color sky #89dceb;
    #   @define-color sapphire #74c7ec;
    #   @define-color blue #89b4fa;
    #   @define-color lavender #b4befe;

    #   @define-color text #cdd6f4;
    #   @define-color subtext1 #bac2de;
    #   @define-color subtext0 #a6adc8;
    #   @define-color overlay2 #9399b2;
    #   @define-color overlay1 #7f849c;
    #   @define-color overlay0 #6c7086;
    #   @define-color surface2 #585b70;
    #   @define-color surface1 #45475a;
    #   @define-color surface0 #313244;
    #   @define-color base #1e1e2e;
    #   @define-color mantle #181825;
    #   @define-color crust #11111b;

    #   * {
    #     font-family: "JetBrainsMono Nerd Font", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
    #     font-size: 13px;
    #   }

    #   window#waybar {
    #     background-color: rgba(17, 17, 27, 0.5);
    #     color: @text;
    #   }

    #   #workspaces button {
    #     padding: 0 5px;
    #     background-color: transparent;
    #     color: @overlay1;
    #     border-radius: 0;
    #   }

    #   #workspaces button.active {
    #     color: @lavender;
    #     border-bottom: 2px solid @lavender;
    #   }

    #   #workspaces button:hover {
    #     background-color: @surface0;
    #   }

    #   #clock, #battery, #cpu, #memory, #network, #pulseaudio, #tray, #window {
    #     padding: 0 10px;
    #     margin: 3px 4px;
    #     border-radius: 8px;
    #     background-color: @mantle;
    #   }

    #   #clock {
    #     background-color: @crust;
    #     color: @text;
    #   }

    #   #mpris {
    #     background-color: @crust;
    #     color: @text;
    #   }

    #   #battery {
    #     background-color: @crust;
    #     color: @text;
    #   }

    #   #battery.charging, #battery.plugged {
    #     background-color: @green;
    #   }

    #   #cpu {
    #     background-color: @crust;
    #     color: @text;
    #   }

    #   #memory {
    #     background-color: @crust;
    #     color: @text;
    #   }

    #   #network {
    #     background-color: @crust;
    #     color: @text;
    #   }

    #   #pulseaudio {
    #     background-color: @crust;
    #     color: @text;
    #   }

    #   #pulseaudio.muted {
    #     background-color: @surface1;
    #   }

    #   #custom-wttrbar {
    #     background-color: @crust;
    #     color: @text;
    #   }
    # '';
  };

  home.packages = with pkgs; [
    waybar
    playerctl
    unstablePkgs.wttrbar
  ];
}
