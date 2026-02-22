{
  config,
  pkgs,
  inputs,
  unstablePkgs,
  lib,
  ...
}:

{
  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
    systemd.variables = [ "--all" ];

    settings = {
      monitor = ",1920x1080,auto,1";
      "$fileManager" = "nautilus";
      env = [
        "QT_QPA_PLATFORM,wayland"
        "GDK_BACKEND,wayland,x11"
      ];

      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "swww init &"
        "waybar &"
        # Stylix will manage the wallpaper
        # "swww img /home/death916/Pictures/wallpapers/jameswebb1.jpg &"
        "dunst &"
        "nm-applet --indicator &"
        "blueman-applet &"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        # Stylix will manage these
        # "col.active_border" = "rgba(cba6f7ee) rgba(1e66f5ee) 45deg";
        # "col.inactive_border" = "rgba(313244aa)";
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        fullscreen_opacity = 1.0;
        blur = {
          enabled = true;
          size = 3;
          passes = 3;
        };
      };

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

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
        };
        sensitivity = 1.0;
      };

      dwindle = {
        pseudotile = true;
        force_split = 2;
      };

      bind = [
        "SUPER, Q, killactive,"
        "SUPER, M, exit,"
        "SUPER, F, fullscreen,"
        "SUPER, Space, togglefloating,"
        "SUPER, P, pseudo,"
        "SUPER, J, togglesplit,"
        "SUPER, L, exec, hyprlock"

        "SUPER, left, movefocus, l"
        "SUPER, right, movefocus, r"
        "SUPER, up, movefocus, u"
        "SUPER, down, movefocus, d"

        "SUPER SHIFT, left, movewindow, l"
        "SUPER SHIFT, right, movewindow, r"
        "SUPER SHIFT, up, movewindow, u"
        "SUPER SHIFT, down, movewindow, d"

        "SUPER CTRL, left, resizeactive, -40 0"
        "SUPER CTRL, right, resizeactive, 40 0"
        "SUPER CTRL, up, resizeactive, 0 -40"
        "SUPER CTRL, down, resizeactive, 0 40"

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

        "SUPER, mouse_down, workspace, e+1"
        "SUPER, mouse_up, workspace, e-1"

        ", XF86AudioMute, exec, ${pkgs.pamixer}/bin/pamixer --toggle-mute"
        ", XF86AudioRaiseVolume, exec, ${pkgs.pamixer}/bin/pamixer --increase 5"
        ", XF86AudioLowerVolume, exec, ${pkgs.pamixer}/bin/pamixer --decrease 5"
        ", XF86AudioPlay, exec, ${pkgs.playerctl}/bin/playerctl play-pause"
        ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +5%"
        ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"

        "SUPER, Return, exec, waveterm"
        "SUPER, T, exec, ghostty"
        "SUPER, D, exec, rofi -show drun"
        "SUPER, A, exec, rofi -show window"
        "SUPER, W, exec, firefox"
        "SUPER, E, exec, nautilus"
        "SUPER, N, exec, dunstctl history-pop"

        "SUPER SHIFT, S, exec, bash -c \"grim -g '$(slurp)' - | tee ~/Pictures/screenshots/$(date +%s).png\""
        "SUPER SHIFT, Print, exec, bash -c \"grim - | tee ~/Pictures/screenshots/$(date +%s).png\""
      ];

      windowrule = [
        "opacity 0.5, match:float yes"
        "opacity 0.8, match:float false"
        "opacity 1.0, match:fullscreen true"
        "idle_inhibit fullscreen, match:fullscreen true"

        # "opacity 1.0 1.0,fullscreen:0"
        # "opacity 0.9 0.9,floating:0"
        # "opacity 0.6 0.6,floating:1"
        "opacity 1.0 override 1.0 override, match:class ^(vlc)$"
        "opacity 1.0 override 1.0 override, match:class ^(jellyfinmediaplayer)$"
        "float 1, match:title ^(Picture-in-Picture)$"
        "float 1, match:class ^(confirm)$"
        "float 1, match:class ^(dialog)$"
        "float 1, match:class ^(file_progress)$"
        "float 1, match:class ^(confirmreset)$"
        "float 1, match:class ^(makeinput)$"
        "float 1, match:class ^(download)$"
        "float 1, match:class ^(notification)$"
        "float 1, match:class ^(error)$"
        "float 1, match:class ^(pinentry)$"
        "float 1, match:class ^(ssh-askpass)$"
        "float 1, match:class ^(lxpolkit)$"
        "float 1, match:class ^(thunar)$"
        "float 1, match:class ^(pavucontrol)$"
        "float 1, match:class ^(blueman-applet)$"
        "float 1, match:class ^(nm-applet)$"
        "no_initial_focus 1, match:class ^(nm-applet)$"
        "no_initial_focus 1, match:class ^(blueman-applet)$"
      ];
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  programs.rofi = {
    enable = true;
    # theme = "arthur"; # Managed by stylix
    extraConfig = {
      modi = "drun,run,ssh,window";
      show-icons = true;
      # icon-theme = "Papirus-Dark"; # Managed by stylix
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      background = lib.mkForce [
        {
          monitor = "";
          path = "/home/death916/Documents/nix-config/home-manager/wallpaper.jpg";
          color = "rgba(0, 0, 0, 0.5)";
          blur_passes = 2;
          blur_size = 5;
        }
      ];

      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 72;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, -50";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:60000] date '+%A, %B %d, %Y'";
          font_size = 20;
          position = "0, 20";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "hyprlock";
      };

      listener = [
        # Lock after 10 minutes of inactivity
        {
          timeout = 600;
          on-timeout = "hyprlock";
        }
        # Turn off display after 10 minutes
        {
          timeout = 750;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        # Suspend the laptop after 30 minutes
        {
          timeout = 2800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

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
        # font = "JetBrainsMono Nerd Font 10"; # Managed by stylix
        line_height = 0;
        notification_height = 0;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        frame_width = 2;
        # frame_color = "#cba6f7"; # Managed by stylix
        # separator_color = "frame"; # Managed by stylix
        word_wrap = true;
        ellipsize = "middle";
        ignore_dbus_close = false;
        force_xinerama = false;
        corner_radius = 10;
        transparency = 5;
        idle_threshold = 120;
        markup = "full";
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
      # The following blocks are managed by stylix
      # urgency_low = {
      #   background = "#1e1e2e";
      #   foreground = "#cdd6f4";
      # };
      # urgency_normal = {
      #   background = "#1e1e2e";
      #   foreground = "#cdd6f4";
      # };
      # urgency_critical = {
      #   background = "#f38ba8";
      #   foreground = "#1e1e2e";
      # };
    };
  };

  services.swww = {
    enable = true;
  };

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    font-awesome
    roboto
    grim
    slurp
    networkmanagerapplet
    blueman
    kitty
    libnotify
    kdePackages.dolphin
    catppuccin-gtk
    materia-theme
    rose-pine-gtk-theme
    nightfox-gtk-theme
    materia-kde-theme

    wl-clipboard
  ];
}
