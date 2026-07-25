{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "workspace special:quake, match:class ^(Wave|waveterm)$"
      "float 1, match:class ^(Wave|waveterm)$"
      "size 80% 80%, match:class ^(Wave|waveterm)$"
      "center 1, match:class ^(Wave|waveterm)$"

      "opacity 0.6, match:float yes"
      "opacity 0.85, match:float false"
      "opacity 1.0, match:fullscreen true"
      "idle_inhibit fullscreen, match:fullscreen true"

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
}
