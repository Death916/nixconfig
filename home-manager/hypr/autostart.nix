{ osConfig, lib, ... }:

{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      "waybar &"
      "poweralertd &"
      "dunst &"
      "nm-applet --indicator &"
      "blueman-applet &"
      "nextcloud --background &"
    ] ++ (lib.optionals (osConfig.networking.hostName == "nix-asus") [
      "systemctl --user start screenpipe"
    ]);
  };
}
