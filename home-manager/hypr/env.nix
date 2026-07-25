{ osConfig, lib, ... }:

{
  wayland.windowManager.hyprland.settings = {
    env = [
      "QT_QPA_PLATFORM,wayland;xcb"
      "GDK_BACKEND,wayland,x11"
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"
    ] ++ (lib.optionals (osConfig.networking.hostName == "death-pc") [
      "LIBVA_DRIVER_NAME,nvidia"
      "XDG_SESSION_TYPE,wayland"
      "GBM_BACKEND,nvidia-drm"
      "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      "NIXOS_OZONE_WL,1"
    ]);
  };
}
