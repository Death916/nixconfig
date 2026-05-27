-- Environment Variables

hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("GDK_BACKEND", "wayland,x11")

if _G.HOSTNAME == "death-pc" then
    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("XDG_SESSION_TYPE", "wayland")
    hl.env("GBM_BACKEND", "nvidia-drm")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
    hl.env("NIXOS_OZONE_WL", "1")
end
