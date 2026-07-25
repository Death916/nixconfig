{ ... }:

{
  wayland.windowManager.hyprland.settings = {
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
      force_split = 2;
    };
    misc = {
      allow_session_lock_restore = true;
    };
  };
}
