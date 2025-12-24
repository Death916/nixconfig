{ config, pkgs, ... }:

{
  stylix.enable = true;

  stylix.wallpaper.paths = [ "/home/death916/Pictures/wallpapers/jameswebb1.jpg" ];
  stylix.wallpaper.mode = "fill"; # Or "stretch", "zoom", "fit"

  stylix.colors = {
    # Base colors (dark to light)
    base00 = "#0f0f0f"; # background
    base01 = "#1a1a1a"; # slightly lighter background for elements (generated)
    base02 = "#706a6a"; # bright_black (for secondary elements, borders)
    base03 = "#808080"; # comments/less prominent text (generated)
    base04 = "#b0b0b0"; # dim foreground (generated)
    base05 = "#eadccc"; # foreground
    base06 = "#f0f0f0"; # brighter foreground (generated)
    base07 = "#ffffff"; # white (pure white for contrast)

    # Accent colors
    base08 = "#e25d6c"; # red
    base09 = "#f4bb54"; # yellow
    base0A = "#e8ab3b"; # cyan
    base0B = "#cea37f"; # green
    base0C = "#e2be8a"; # blue
    base0D = "#e8ab3b"; # cyan (using cyan for purple-ish if needed, or adjust)
    base0E = "#ede4c8"; # magenta (using original magenta)
    base0F = "#ff8800"; # a generic amber/orange (generated, could be 'yellow')
  };

  stylix.cursor = {
    package = pkgs.catppuccin-cursors; # Existing cursor
    name = "Catppuccin-Mocha-Dark-Cursors"; # Existing cursor
    size = 24; # Existing size
  };

  stylix.fonts = {
    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
    serif = {
      package = pkgs.noto-fonts;
      name = "Noto Serif"; # Placeholder
      size = 10;
    };
    sansSerif = {
      package = pkgs.noto-fonts;
      name = "Noto Sans"; # Placeholder
      size = 10;
    };
    emoji = {
      package = pkgs.noto-fonts-color-emoji;
      name = "Noto Color Emoji";
      size = 10;
    };
  };

  stylix.targets = {
    desktop.enable = true; # Theme desktop environment components
    gtk.enable = true;
    kde.enable = true; # KDE is for QT applications
    plymouth.enable = true;
    plasma.enable = true; # For KDE Plasma
  };

  stylix.extraPackageModules = [
    { config, pkgs, ... }: {
      programs.hyprland.settings.general.col.active_border = "rgb(${config.stylix.colors.base0C})"; # Blue
      programs.hyprland.settings.general.col.inactive_border = "rgb(${config.stylix.colors.base00})"; # Background
    }
  ];

  programs.waybar = {
    enable = true;
    settings = config.stylix.waybar.settings; # Let stylix manage waybar settings
    style = config.stylix.waybar.css; # Let stylix generate the CSS
  };

  programs.rofi = {
    enable = true;
    theme = config.stylix.rofi.theme; # Let stylix manage rofi theme
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        frame_color = config.stylix.colors.base0C; # Blue accent
        background = config.stylix.colors.base00;
        foreground = config.stylix.colors.base05;
      };
      urgency_low = {
        background = config.stylix.colors.base00;
        foreground = config.stylix.colors.base05;
      };
      urgency_normal = {
        background = config.stylix.colors.base00;
        foreground = config.stylix.colors.base05;
      };
      urgency_critical = {
        background = config.stylix.colors.base08; # Red accent
        foreground = config.stylix.colors.base00;
      };
    };
  };
}
