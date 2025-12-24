{ config, pkgs, ... }:

{
  stylix.enable = true;

  stylix.image = "/home/death916/Pictures/wallpapers/jameswebb1.jpg";

  stylix.base16Scheme = {
    base00 = "#0f0f0f"; # background
    base01 = "#1a1a1a"; # slightly lighter background
    base02 = "#706a6a"; # bright_black
    base03 = "#808080"; # comments
    base04 = "#b0b0b0"; # dim foreground
    base05 = "#eadccc"; # foreground
    base06 = "#f0f0f0"; # brighter foreground
    base07 = "#ffffff"; # white
    base08 = "#e25d6c"; # red
    base09 = "#f4bb54"; # yellow
    base0A = "#e8ab3b"; # cyan
    base0B = "#cea37f"; # green
    base0C = "#e2be8a"; # blue
    base0D = "#e8ab3b"; # cyan (duplicate)
    base0E = "#ede4c8"; # magenta
    base0F = "#ff8800"; # amber/orange
  };

  stylix.cursor = {
    package = pkgs.catppuccin-cursors;
    name = "Catppuccin-Mocha-Dark-Cursors";
    size = 24;
  };

  stylix.fonts = {
    monospace = {
      package = pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font";
    };
    sansSerif = {
      package = pkgs.noto-fonts;
      name = "Noto Sans";
    };
    serif = {
      package = pkgs.noto-fonts;
      name = "Noto Serif";
    };
    emoji = {
      package = pkgs.noto-fonts-color-emoji;
      name = "Noto Color Emoji";
    };
  };

  stylix.targets = {
    hyprland.enable = true;
    waybar.enable = true;
    rofi.enable = true;
    dunst.enable = true;
    gtk.enable = true;
    kde.enable = true;
    plymouth.enable = true;
    plasma.enable = true;
  };
}