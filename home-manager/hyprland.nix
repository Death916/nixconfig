{
  pkgs,
  inputs,
  unstablePkgs,
  ...
}:

{
  # Enable Hyprland and XWayland
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
    systemd.variables = [ "--all" ]; # Ensure environment variables are passed to systemd service # For XWayland applications

    # Hyprland configuration settings
    settings = {
      # Monitors
      monitor = ",1920x1080,auto,1"; # Set primary monitor to 1080p

      # Execute on startup
      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "swww init &" # Wallpaper daemon
        "waybar &" # Start Waybar
        "swww img /home/death916/Pictures/wallpapers/jameswebb1.jpg &"
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
        fullscreen_opacity = 1.0;
        blur = {
          enabled = true;
          size = 3;
          passes = 3;
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
      # gestures = {
      #   workspace_swipe = true;
      # };

      # Keybindings
      bind = [
        # Window management
        "SUPER, Q, killactive,"
        "SUPER, M, exit,"
        "SUPER, F, fullscreen,"
        "SUPER, Space, togglefloating,"
        "SUPER, P, pseudo," # Master switch for pseudotiling.
        "SUPER, J, togglesplit," # Master switch for splitting.
        "SUPER, L, exec, hyprlock" # Lock the screen

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

        # Resize active window
        "SUPER SHIFT, right, resizeactive, 10 0"
        "SUPER SHIFT, left, resizeactive, -10 0"
        "SUPER SHIFT, down, resizeactive, 0 -10 0 -10"
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

        # Window resizing
        "SUPER, R, submap, resize"
        # "submap = resize"
        # # "binde = , right, resizeactive, 10 0"
        # # "binde = , left, resizeactive, -10 0"
        # # "binde = , up, resizeactive, 0 -10"
        # # "binde = , down, resizeactive, 0 10"
        # "bind = , escape, submap, reset"
        # "submap = reset"

        # Multimedia keys
        ", XF86AudioMute, exec, ${pkgs.pamixer}/bin/pamixer --toggle-mute"
        ", XF86AudioRaiseVolume, exec, ${pkgs.pamixer}/bin/pamixer --increase 5"
        ", XF86AudioLowerVolume, exec, ${pkgs.pamixer}/bin/pamixer --decrease 5"
        ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"

        # Application launchers
        "SUPER, Return, exec, waveterm" # Terminal
        "SUPER, T, exec, ghostty" # Wave Terminal
        "SUPER, D, exec, rofi -show drun" # Rofi application launcher
        "SUPER, A, exec, rofi -show window"
        "SUPER, W, exec, microsoft-edge"
        "SUPER, E, exec, nautilus" # File manager
        "SUPER, N, exec, dunstctl history-pop"
        # Screenshots
        "SUPER SHIFT, S, exec, bash -c \"grim -g '$(slurp)' - | tee ~/Pictures/screenshots/$(date +%s).png | wl-copy\"" # Screenshot selection to clipboard
        "SUPER SHIFT, Print, exec, bash -c \"grim - | tee ~/Pictures/screenshots/$(date +%s).png | wl-copy\"" # Screenshot full screen to clipboard
      ];

      # Window rules
      windowrule = [
        "opacity 1.0 1.0,fullscreen:0"
        "opacity 0.9 0.9,floating:0"
        "opacity 0.6 0.6,floating:1"
        "opacity 1.0 1.0,class:^(vlc)$"
        "opacity 1.0 1.0,class:^(jellyfinmediaplayer)$"
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
        "float,class:^(thunar)"
        "float,class:^(pavucontrol)"
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
      xdg-desktop-portal-gtk
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
        modules-left = [
          "tray"
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
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
          format = "{:%Y-%m-%d %H:%M:%S}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        "pulseaudio" = {
          format = "{icon} {volume}%";
          format-muted = " Muted";
          format-icons = {
            "default" = [
              ""
              ""
              ""
            ];
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
      /*
      * Catppuccin Mocha
      */

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
        font-family: "JetBrainsMono Nerd Font", FontAwesome, Roboto, Helvetica, Arial, sans-serif;
        font-size: 13px;
      }

      window#waybar {
        background-color: @crust;
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

      #clock, #battery, #cpu, #memory, #network, #pulseaudio, #tray, #window {
        padding: 0 10px;
        margin: 3px 4px;
        border-radius: 8px;
        background-color: @mantle;
      }

      #clock {
        background-color: @blue;
        color: @crust;
      }

      #battery {
        background-color: @red;
        color: @crust;
      }

      #battery.charging, #battery.plugged {
        background-color: @green;
      }

      #cpu {
        background-color: @yellow;
        color: @crust;
      }

      #memory {
        background-color: @peach;
        color: @crust;
      }

      #network {
        background-color: @green;
        color: @crust;
      }

      #pulseaudio {
        background-color: @mauve;
        color: @crust;
      }

      #pulseaudio.muted {
        background-color: @surface1;
      }

      #custom-wttrbar {
        background-color: @teal;
        color: @crust;
      }
    '';

  };

  # Rofi (application launcher)
  programs.rofi = {
    enable = true;
    theme = "arthur"; # Use a Catppuccin theme for Rofi
    extraConfig = {
      modi = "drun,run,ssh,window";
      show-icons = true;
      icon-theme = "Papirus-Dark";
    };
  };

  programs.hyprlock = {
    enable = true;
  };

  # Dunst (notification daemon)
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "keyboard";
        width = 300;
        height = 150;
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
        # format = "<b>%s</b>\n%b";
        format = "<small>%a</small>\n<big><b>%s</b></big>\n%b";
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
    gtk3 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    gtk4 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    theme = {

      name = "Materia-dark";
      package = pkgs.materia-theme;
      #name = "Catppuccin-Mocha-Standard-Lavender-Dark";
      #package = pkgs.catppuccin-gtk.override {
      #accents = [ "lavender" ];
      #size = "standard";
      #variant = "mocha";
      #};
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

  # Qt Theming
  qt = {
    enable = true;
    platformTheme.name = "qt5gtk2";
  };
  home.sessionVariables = {
    #QT_QPA_PLATFORMTHEME = "gtk";  # Required for Qt apps like VLC
    QT_STYLE_OVERRIDE = "qt5gtk2";
  };

  # Fonts
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    font-awesome
    roboto
    grim
    slurp
    networkmanagerapplet
    blueman
    waybar
    kitty
    libnotify
    kdePackages.dolphin
    catppuccin-gtk
    materia-theme
    rose-pine-gtk-theme
    nightfox-gtk-theme
    materia-kde-theme

    playerctl
    wl-clipboard
    unstablePkgs.wttrbar
  ];
}
