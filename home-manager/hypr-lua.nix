{
  config,
  osConfig,
  pkgs,
  inputs,
  unstablePkgs,
  lib,
  ...
}:

let
  ml = lib.generators.mkLuaInline;
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
    systemd.variables = [ "--all" ];

    settings = {
      monitor =
        if (osConfig.networking.hostName == "death-pc") then
          [
            { output = "desc:Acer Technologies R240HY T4BAA0012400"; mode = "1920x1080"; position = "-1920x0"; scale = 1; }
            { output = "desc:BNQ BenQ EL2870U 26M05467SL0"; mode = "2560x1440"; position = "0x0"; scale = 1; }
            { output = "desc:WAM U24C 0000000000001"; mode = "1920x1080"; position = "2560x0"; scale = 1; }
          ]
        else if (osConfig.networking.hostName == "nix-asus") then
          [
            { output = "eDP-1"; mode = "2880x1800@120"; position = "0x0"; scale = 1.25; }
          ]
        else
          [
            { output = ""; mode = "preferred"; position = "auto"; scale = 1; }
          ];

      config = {
        xwayland = {
          force_zero_scaling = true;
        };

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
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

        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad = {
            natural_scroll = true;
          };
          sensitivity = 1.0;
        };

        dwindle = {
          force_split = 2;
        };

        misc = {
          allow_session_lock_restore = true;
        };
      };

      workspace_rule =
        if (osConfig.networking.hostName == "death-pc") then
          [
            { workspace = "1"; monitor = "desc:BNQ BenQ EL2870U 26M05467SL0"; }
            { workspace = "2"; monitor = "desc:Acer Technologies R240HY T4BAA0012400"; }
            { workspace = "3"; monitor = "desc:WAM U24C 0000000000001"; }
          ]
        else
          [ ];

      env = [
        { _args = [ "QT_QPA_PLATFORM" "wayland;xcb" ]; }
        { _args = [ "GDK_BACKEND" "wayland,x11" ]; }
        { _args = [ "XCURSOR_SIZE" "24" ]; }
        { _args = [ "HYPRCURSOR_SIZE" "24" ]; }
      ]
      ++ (lib.optionals (osConfig.networking.hostName == "death-pc") [
        { _args = [ "LIBVA_DRIVER_NAME" "nvidia" ]; }
        { _args = [ "XDG_SESSION_TYPE" "wayland" ]; }
        { _args = [ "GBM_BACKEND" "nvidia-drm" ]; }
        { _args = [ "__GLX_VENDOR_LIBRARY_NAME" "nvidia" ]; }
        { _args = [ "NIXOS_OZONE_WL" "1" ]; }
      ]);

      curve = {
        _args = [
          "myBezier"
          { type = "bezier"; points = [ [ 0.05 0.9 ] [ 0.1 1.05 ] ]; }
        ];
      };

      animation = [
        { leaf = "windows"; enabled = true; speed = 7; bezier = "myBezier"; }
        { leaf = "windowsOut"; enabled = true; speed = 7; bezier = "default"; style = "popin 80%"; }
        { leaf = "border"; enabled = true; speed = 10; bezier = "default"; }
        { leaf = "borderangle"; enabled = true; speed = 8; bezier = "default"; }
        { leaf = "fade"; enabled = true; speed = 7; bezier = "default"; }
        { leaf = "workspaces"; enabled = true; speed = 6; bezier = "default"; }
      ];

      bind = [
        { _args = [ "SUPER+Q" (ml "hl.dsp.window.close()") ]; }
        { _args = [ "SUPER+F" (ml "hl.dsp.window.fullscreen()") ]; }
        { _args = [ "SUPER+Space" (ml "hl.dsp.window.float()") ]; }
        { _args = [ "SUPER+P" (ml "hl.dsp.window.pseudo()") ]; }
        { _args = [ "SUPER+J" (ml ''hl.dsp.layout("togglesplit")'') ]; }
        { _args = [ "SUPER+L" (ml ''hl.dsp.exec_cmd("hyprlock")'') ]; }

        { _args = [ "SUPER+left" (ml ''hl.dsp.focus({ direction = "left" })'') ]; }
        { _args = [ "SUPER+right" (ml ''hl.dsp.focus({ direction = "right" })'') ]; }
        { _args = [ "SUPER+up" (ml ''hl.dsp.focus({ direction = "up" })'') ]; }
        { _args = [ "SUPER+down" (ml ''hl.dsp.focus({ direction = "down" })'') ]; }

        { _args = [ "SUPER+SHIFT+left" (ml ''hl.dsp.window.move({ direction = "left" })'') ]; }
        { _args = [ "SUPER+SHIFT+right" (ml ''hl.dsp.window.move({ direction = "right" })'') ]; }
        { _args = [ "SUPER+SHIFT+up" (ml ''hl.dsp.window.move({ direction = "up" })'') ]; }
        { _args = [ "SUPER+SHIFT+down" (ml ''hl.dsp.window.move({ direction = "down" })'') ]; }

        { _args = [ "SUPER+CTRL+left" (ml ''hl.dsp.window.resize({ x = -40, y = 0, relative = true })'') ]; }
        { _args = [ "SUPER+CTRL+right" (ml ''hl.dsp.window.resize({ x = 40, y = 0, relative = true })'') ]; }
        { _args = [ "SUPER+CTRL+up" (ml ''hl.dsp.window.resize({ x = 0, y = -40, relative = true })'') ]; }
        { _args = [ "SUPER+CTRL+down" (ml ''hl.dsp.window.resize({ x = 0, y = 40, relative = true })'') ]; }

        { _args = [ "SUPER+1" (ml ''hl.dsp.focus({ workspace = "1" })'') ]; }
        { _args = [ "SUPER+2" (ml ''hl.dsp.focus({ workspace = "2" })'') ]; }
        { _args = [ "SUPER+3" (ml ''hl.dsp.focus({ workspace = "3" })'') ]; }
        { _args = [ "SUPER+4" (ml ''hl.dsp.focus({ workspace = "4" })'') ]; }
        { _args = [ "SUPER+5" (ml ''hl.dsp.focus({ workspace = "5" })'') ]; }
        { _args = [ "SUPER+6" (ml ''hl.dsp.focus({ workspace = "6" })'') ]; }
        { _args = [ "SUPER+7" (ml ''hl.dsp.focus({ workspace = "7" })'') ]; }
        { _args = [ "SUPER+8" (ml ''hl.dsp.focus({ workspace = "8" })'') ]; }
        { _args = [ "SUPER+9" (ml ''hl.dsp.focus({ workspace = "9" })'') ]; }
        { _args = [ "SUPER+0" (ml ''hl.dsp.focus({ workspace = "10" })'') ]; }

        { _args = [ "SUPER+SHIFT+1" (ml ''hl.dsp.window.move({ workspace = "1" })'') ]; }
        { _args = [ "SUPER+SHIFT+2" (ml ''hl.dsp.window.move({ workspace = "2" })'') ]; }
        { _args = [ "SUPER+SHIFT+3" (ml ''hl.dsp.window.move({ workspace = "3" })'') ]; }
        { _args = [ "SUPER+SHIFT+4" (ml ''hl.dsp.window.move({ workspace = "4" })'') ]; }
        { _args = [ "SUPER+SHIFT+5" (ml ''hl.dsp.window.move({ workspace = "5" })'') ]; }
        { _args = [ "SUPER+SHIFT+6" (ml ''hl.dsp.window.move({ workspace = "6" })'') ]; }
        { _args = [ "SUPER+SHIFT+7" (ml ''hl.dsp.window.move({ workspace = "7" })'') ]; }
        { _args = [ "SUPER+SHIFT+8" (ml ''hl.dsp.window.move({ workspace = "8" })'') ]; }
        { _args = [ "SUPER+SHIFT+9" (ml ''hl.dsp.window.move({ workspace = "9" })'') ]; }
        { _args = [ "SUPER+SHIFT+0" (ml ''hl.dsp.window.move({ workspace = "10" })'') ]; }

        { _args = [ "SUPER+mouse_down" (ml ''hl.dsp.focus({ workspace = "+1" })'') ]; }
        { _args = [ "SUPER+mouse_up" (ml ''hl.dsp.focus({ workspace = "-1" })'') ]; }

        { _args = [ "XF86AudioMute" (ml ''hl.dsp.exec_cmd("${pkgs.pamixer}/bin/pamixer --toggle-mute")'') ]; }
        { _args = [ "XF86AudioRaiseVolume" (ml ''hl.dsp.exec_cmd("${pkgs.pamixer}/bin/pamixer --increase 5")'') ]; }
        { _args = [ "XF86AudioLowerVolume" (ml ''hl.dsp.exec_cmd("${pkgs.pamixer}/bin/pamixer --decrease 5")'') ]; }
        { _args = [ "XF86AudioPlay" (ml ''hl.dsp.exec_cmd("${pkgs.playerctl}/bin/playerctl play-pause")'') ]; }
        { _args = [ "XF86MonBrightnessUp" (ml ''hl.dsp.exec_cmd("${pkgs.brightnessctl}/bin/brightnessctl set +5%")'') ]; }
        { _args = [ "XF86MonBrightnessDown" (ml ''hl.dsp.exec_cmd("${pkgs.brightnessctl}/bin/brightnessctl set 5%-")'') ]; }

        { _args = [ "SUPER+grave" (ml ''hl.dsp.workspace.toggle_special("quake")'') ]; }
        { _args = [ "SUPER+M" (ml ''hl.dsp.window.move({ workspace = "special:minimized" })'') ]; }
        { _args = [ "SUPER+SHIFT+M" (ml ''hl.dsp.workspace.toggle_special("minimized")'') ]; }
        { _args = [ "SUPER+S" (ml ''hl.dsp.workspace.toggle_special("minimized")'') ]; }

        { _args = [ "SUPER+Return" (ml ''hl.dsp.exec_cmd("waveterm")'') ]; }
        { _args = [ "SUPER+T" (ml ''hl.dsp.exec_cmd("ghostty")'') ]; }
        { _args = [ "SUPER+D" (ml ''hl.dsp.exec_cmd("rofi -show drun")'') ]; }
        { _args = [ "SUPER+A" (ml ''hl.dsp.exec_cmd("rofi -show window")'') ]; }
        { _args = [ "SUPER+W" (ml ''hl.dsp.exec_cmd("firefox")'') ]; }
        { _args = [ "SUPER+E" (ml ''hl.dsp.exec_cmd("nautilus")'') ]; }
        { _args = [ "SUPER+N" (ml ''hl.dsp.exec_cmd("dunstctl history-pop")'') ]; }
        { _args = [ "SUPER+SHIFT+N" (ml ''hl.dsp.exec_cmd("dunstctl close-all")'') ]; }

        { _args = [ "SUPER+SHIFT+S" (ml ''hl.dsp.exec_cmd("bash -c \"grim -g '$(slurp)' - | tee ~/Pictures/screenshots/$(date +%s).png\"")'') ]; }
        { _args = [ "SUPER+SHIFT+Print" (ml ''hl.dsp.exec_cmd("bash -c \"grim - | tee ~/Pictures/screenshots/$(date +%s).png\"")'') ]; }
      ];

      window_rule = [
        { match = { class = "^(Wave|waveterm)$"; }; workspace = "special:quake"; }
        { match = { class = "^(Wave|waveterm)$"; }; float = true; }
        { match = { class = "^(Wave|waveterm)$"; }; size = "80% 80%"; }
        { match = { class = "^(Wave|waveterm)$"; }; center = true; }

        { match = { float = true; }; opacity = "0.6"; }
        { match = { float = false; }; opacity = "0.85"; }
        { match = { fullscreen = true; }; opacity = "1.0"; }
        { match = { fullscreen = true; }; idle_inhibit = "fullscreen"; }

        { match = { class = "^(vlc)$"; }; opacity = "1.0 override 1.0 override"; }
        { match = { class = "^(jellyfinmediaplayer)$"; }; opacity = "1.0 override 1.0 override"; }
        { match = { title = "^(Picture-in-Picture)$"; }; float = true; }
        { match = { class = "^(confirm)$"; }; float = true; }
        { match = { class = "^(dialog)$"; }; float = true; }
        { match = { class = "^(file_progress)$"; }; float = true; }
        { match = { class = "^(confirmreset)$"; }; float = true; }
        { match = { class = "^(makeinput)$"; }; float = true; }
        { match = { class = "^(download)$"; }; float = true; }
        { match = { class = "^(notification)$"; }; float = true; }
        { match = { class = "^(error)$"; }; float = true; }
        { match = { class = "^(pinentry)$"; }; float = true; }
        { match = { class = "^(ssh-askpass)$"; }; float = true; }
        { match = { class = "^(lxpolkit)$"; }; float = true; }
        { match = { class = "^(thunar)$"; }; float = true; }
        { match = { class = "^(pavucontrol)$"; }; float = true; }
        { match = { class = "^(blueman-applet)$"; }; float = true; }
        { match = { class = "^(nm-applet)$"; }; float = true; }
        { match = { class = "^(nm-applet)$"; }; no_initial_focus = true; }
        { match = { class = "^(blueman-applet)$"; }; no_initial_focus = true; }
      ];
    };

    extraConfig = ''
      hl.on("hyprland.start", function()
        hl.exec_cmd("waybar")
        hl.exec_cmd("poweralertd")
        hl.exec_cmd("dunst")
        hl.exec_cmd("nm-applet --indicator")
        hl.exec_cmd("blueman-applet")
        hl.exec_cmd("nextcloud --background")
        ${lib.optionalString (osConfig.networking.hostName == "nix-asus") ''
          hl.exec_cmd("systemctl --user start screenpipe")
        ''}
      end)
    '';
  };

  xdg.portal = {
    enable = lib.mkForce false;
  };

  programs.rofi = {
    enable = true;
    extraConfig = {
      modi = "drun,run,ssh,window";
      show-icons = true;
    };
  };

  programs.hyprlock = {
    enable = true;
    package = unstablePkgs.hyprlock;
    settings = {
      general = {
        no_fade_in = true;
        no_fade_out = true;
        ignore_empty_input = false;
      };

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
        {
          timeout = 600;
          on-timeout = "hyprlock";
        }
        {
          timeout = 750;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        (lib.mkIf (osConfig.networking.hostName != "death-pc") {
          timeout = 2800;
          on-timeout = "systemctl suspend";
        })
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
        line_height = 0;
        notification_height = 0;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        frame_width = 2;
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