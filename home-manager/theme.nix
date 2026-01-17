{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./themes/ferra.nix
  ];

  stylix.enable = true;
  stylix.polarity = "dark";

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
    zed.enable = true;
    zed.colors.enable = true;
    zellij.enable = true;
    zellij.colors.enable = true;
    btop.enable = true;
    halloy.enable = true;
    qt.enable = true;
    firefox.enable = true;
  };
}
