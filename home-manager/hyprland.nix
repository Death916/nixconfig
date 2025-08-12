{ pkgs, ... }:

{
  # Enable Hyprland and XWayland
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.variables = ["--all"]; # Ensure environment variables are passed to systemd service # For XWayland applications

    # Hyprland configuration settings
    settings = {
      # Monitors
      monitor = ",1920x1080,auto,1"; # Set primary monitor to 1080p

      # Execute on startup
      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "swww init &" # Wallpaper daemon
        "swww img /path/to/your/wallpaper.jpg &" # Set your wallpaper path here
        "waybar &" # Start Waybar
        "dunst &" # Start Dunst notification daemon
        "nm-applet --indicator &" # NetworkManager applet
        "blueman-applet &" # Bluetooth applet
      ];

      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(cba6f7ee) rgba(1e66f5ee) 45deg"; # Catppuccin Lavender/Blue
        "col.inactive_border" = "rgba(313244aa)"; # Catppuccin Surface0
        layout = "dwindle"; # Or "master", "tile"
      };

      # Decoration
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        # drop_shadow = true;
        # shadow_range = 4;
        # shadow_render_power = 3;
        # "col.shadow" = "rgba(1a1a1aee)";
      };

      # Animations
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Input
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
        sensitivity = 1.0; # 0.0 - 1.0, 1.0 = no modification
      };

      # Dwindle layout (default)
      dwindle = {
        pseudotile = true; # Master switch for pseudotiling. Enabling this means windows will not resize when moved into a master area.
        force_split = 2; # Master switch for forcing splitting.
      };

      # Gestures
      gestures = {
        workspace_swipe = true;
      };

      # Keybindings
      bind = [
        # Window management
        "SUPER, Q, killactive,"
        "SUPER, M, exit,"
        "SUPER, F, fullscreen,"
        "SUPER, Space, togglefloating,"
        "SUPER, P, pseudo," # Master switch for pseudotiling.
        "SUPER, J, togglesplit," # Master switch for splitting.

        # Move focus
        "SUPER, left, movefocus, l"
        "SUPER, right, movefocus, r"
        "SUPER, up, movefocus, u"
        "SUPER, down, movefocus, d"

        # Move windows
        "SUPER SHIFT, left, movewindow, l"
        "SUPER SHIFT, right, movewindow, r"
        "SUPER SHIFT, up, movewindow, u"
        "SUPER SHIFT, down, movewindow, d"

        # Workspaces
        "SUPER, 1, workspace, 1"
        "SUPER, 2, workspace, 2"
        "SUPER, 3, workspace, 3"
        "SUPER, 4, workspace, 4"
        "SUPER, 5, workspace, 5"
        "SUPER, 6, workspace, 6"
        "SUPER, 7, workspace, 7"
        "SUPER, 8, workspace, 8"
        "SUPER, 9, workspace, 9"
        "SUPER, 0, workspace, 10"

        # Move window to workspace
        "SUPER SHIFT, 1, movetoworkspace, 1"
        "SUPER SHIFT, 2, movetoworkspace, 2"
        "SUPER SHIFT, 3, movetoworkspace, 3"
        "SUPER SHIFT, 4, movetoworkspace, 4"
        "SUPER SHIFT, 5, movetoworkspace, 5"
        "SUPER SHIFT, 6, movetoworkspace, 6"
        "SUPER SHIFT, 7, movetoworkspace, 7"
        "SUPER SHIFT, 8, movetoworkspace, 8"
        "SUPER SHIFT, 9, movetoworkspace, 9"
        "SUPER SHIFT, 0, movetoworkspace, 10"

        # Scroll through workspaces
        "SUPER, mouse_down, workspace, e+1"
        "SUPER, mouse_up, workspace, e-1"

        # Multimedia keys
        "XF86AudioMute, exec, sh -c "${pkgs.pamixer}/bin/pamixer --toggle-mute}""
        "XF86AudioRaiseVolume, exec, sh -c "${pkgs.pamixer}/bin/pamixer --increase 5}""
        "XF86AudioLowerVolume, exec, sh -c "${pkgs.pamixer}/bin/pamixer --decrease 5}""
        "XF86MonBrightnessUp, exec, sh -c "${pkgs.brightnessctl}/bin/brightnessctl set +5%}""
        "XF86MonBrightnessDown, exec, sh -c "${pkgs.brightnessctl}/bin/brightnessctl set 5%-}"

        # Application launchers
        "SUPER, Return, exec, alacritty" # Terminal
        "SUPER, T, exec, waveterm" # Wave Terminal
        "SUPER, D, exec, rofi -show drun" # Rofi application launcher
        "SUPER, W, exec, firefox" # Web browser
        "SUPER, E, exec, ${pkgs.kdePackages.dolphin}" # File manager

        # Screenshots
        "SUPER, Print, exec, grim -g \"$(slurp)\" - | wl-copy" # Screenshot selection to clipboard
        "SUPER SHIFT, Print, exec, grim - | wl-copy" # Screenshot full screen to clipboard
      ];

      # Window rules
      windowrulev2 = [
        "float,title:^(Picture-in-Picture)$"
        "float,class:^(confirm)$"
        "float,class:^(dialog)$"
        "float,class:^(file_progress)$"
        "float,class:^(confirmreset)$"
        "float,class:^(makeinput)$"
        "float,class:^(dialog)$"
        "float,class:^(download)$"
        "float,class:^(notification)$"
        "float,class:^(error)$"
        "float,class:^(pinentry)$"
        "float,class:^(ssh-askpass)$"
        "float,class:^(lxpolkit)$"
        "float,class:^(thunar)" # Example: float Thunar if you prefer
        "float,class:^(pavucontrol)" # Example: float Pavucontrol
        "float,class:^(blueman-applet)"
        "float,class:^(nm-applet)"
        "nofocus,class:^(nm-applet)"
        "nofocus,class:^(blueman-applet)"
      ];
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
    ];
  };

  # Waybar (status bar)
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "cpu" "memory" "battery" ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "󰎤"; # 1
            "2" = "󰎧"; # 2
            "3" = "󰎪"; # 3
            "4" = "󰎭"; # 4
            "5" = "󰎱"; # 5
            "6" = "󰎳"; # 6
            "7" = "󰎶"; # 7
            "8" = "󰎹"; # 8
            "9" = "󰎼"; # 9
            "10" = "󰎿"; # 10
            "active" = "";
            "default" = "";
          };
        };

        "hyprland/window" = {
          max-length = 50;
        };

        "clock" = {
          format = " {:%H:%M:%S}  {:%Y-%m-%d}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = " Muted";
          format-icons = {
            "default" = [ "" "" "" ];
          };
        };

        "network" = {
          format-wifi = " {essid} ({signalStrength}%)";
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
          format-icons = [ "" "" "" "" "" ];
        };
      };
    };
    style = ''
      /* Catppuccin Mocha colors */
      @define-color rosewater #f5e0dc;
      @define-color flamingo #f2cdcd;
      @define-color pink #f5c2e7;
      @define-color mauve #cba6f7;
      @define-color red #f38ba8;
      @define-color maroon #eba0ac;
      @define-color peach #fab387;
      @define-color yellow #f9e2af;
      @define-color green #a6e3a1;
      @define-color teal #94e2d5;
      @define-color sky #89dceb;
      @define-color sapphire #74c7ec;
      @define-color blue #89b4fa;
      @define-color lavender #b4befe;
      @define-color text #cdd6f4;
      @define-color subtext1 #bac2de;
      @define-color subtext0 #a6adc8;
      @define-color overlay2 #9399b2;
      @define-color overlay1 #7f849c;
      @define-color overlay0 #6c7086;
      @define-color surface2 #585b70;
      @define-color surface1 #45475a;
      @define-color surface0 #313244;
      @define-color base #1e1e2e;
      @define-color mantle #181825;
      @define-color crust #11111b;

      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 13px;
      }

      window#waybar {
        background-color: @crust;
        border-bottom: 2px solid @surface0;
        color: @text;
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: @overlay1;
        border-radius: 0;
      }

      #workspaces button.active {
        color: @lavender;
        border-bottom: 2px solid @lavender;
      }

      #workspaces button:hover {
        background-color: @surface0;
      }

      #window, #clock, #pulseaudio, #network, #cpu, #memory, #battery {
        padding: 0 10px;
        background-color: @mantle;
        margin: 0 4px;
        border-radius: 8px;
      }

      #pulseaudio.muted {
        color: @red;
      }

      #battery.charging, #battery.plugged {
        color: @green;
      }

      #battery.warning:not(.charging) {
        color: @yellow;
      }

      #battery.critical:not(.charging) {
        color: @red;
      }
    '';
  };

  # Rofi (application launcher)
  programs.rofi = {
    enable = true;
    theme = "catppuccin"; # Use a Catppuccin theme for Rofi
    extraConfig = {
      modi = "drun,run,ssh";
      show-icons = true;
      icon-theme = "Papirus-Dark";
    };
  };

  # Dunst (notification daemon)
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "keyboard";
        width = 300;
        height = 50;
        offset = "10x50";
        origin = "top-right";
        font = "JetBrainsMono Nerd Font 10";
        line_height = 0;
        notification_height = 0;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        frame_width = 2;
        frame_color = "#cba6f7"; # Catppuccin Lavender
        separator_color = "frame";
        word_wrap = true;
        ellipsize = "middle";
        ignore_dbus_close = false;
        force_xinerama = false;
        corner_radius = 10;
        transparency = 5;
        idle_threshold = 120;
        markup = "full";
        format = "<b>%s</b>\n%b";
        alignment = "left";
        bounce_freq = 0;
        show_age_threshold = 60;
        icon_position = "left";
        max_icon_size = 32;
        sticky_history = true;
        history_length = 20;
        browser = "${pkgs.firefox}/bin/firefox";
        always_run_script = true;
        startup_notification = false;
        indicate_hidden = true;
        shrink = false;
        close_on_click = true;
        sort = true;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;
      };
      urgency_low = {
        background = "#1e1e2e"; # Catppuccin Base
        foreground = "#cdd6f4"; # Catppuccin Text
      };
      urgency_normal = {
        background = "#1e1e2e"; # Catppuccin Base
        foreground = "#cdd6f4"; # Catppuccin Text
      };
      urgency_critical = {
        background = "#f38ba8"; # Catppuccin Red
        foreground = "#1e1e2e"; # Catppuccin Base
      };
    };
  };

  # Wallpaper setter
  services.swww = {
    enable = true;
    # You'll set the actual wallpaper in exec-once in Hyprland settings
  };

  # GTK Theming
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Standard-Lavender-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "lavender" ];
        size = "standard";
        variant = "mocha";
      };
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Catppuccin-Mocha-Dark-Cursors";
      package = pkgs.catppuccin-cursors;
      size = 24;
    };
  };

  # Fonts
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    # Nerd Fonts for icons in Waybar, Rofi, etc.
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome # For some older icons
    # Tools for screenshots
    grim # Screenshot tool
    slurp # Selection tool for grim
    # Network/Bluetooth applets
    networkmanagerapplet
    blueman
    waybar # Ensure waybar is installed
    kitty
    libnotify # For dunst
    kdePackages.dolphin
  ];
}
