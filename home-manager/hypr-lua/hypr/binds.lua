-- Keybindings

local fileManager = "nautilus"

local binds = {
    -- mod, key, dispatcher, arg
    { "SUPER", "Q", "killactive", "" },
    { "SUPER", "F", "fullscreen", "" },
    { "SUPER", "Space", "togglefloating", "" },
    { "SUPER", "P", "pseudo", "" },
    { "SUPER", "J", "layoutmsg", "togglesplit" },
    { "SUPER", "L", "exec", "hyprlock" },

    { "SUPER", "left", "movefocus", "l" },
    { "SUPER", "right", "movefocus", "r" },
    { "SUPER", "up", "movefocus", "u" },
    { "SUPER", "down", "movefocus", "d" },

    { "SUPER SHIFT", "left", "movewindow", "l" },
    { "SUPER SHIFT", "right", "movewindow", "r" },
    { "SUPER SHIFT", "up", "movewindow", "u" },
    { "SUPER SHIFT", "down", "movewindow", "d" },

    { "SUPER CTRL", "left", "resizeactive", "-40 0" },
    { "SUPER CTRL", "right", "resizeactive", "40 0" },
    { "SUPER CTRL", "up", "resizeactive", "0 -40" },
    { "SUPER CTRL", "down", "resizeactive", "0 40" },

    { "SUPER", "1", "workspace", "1" },
    { "SUPER", "2", "workspace", "2" },
    { "SUPER", "3", "workspace", "3" },
    { "SUPER", "4", "workspace", "4" },
    { "SUPER", "5", "workspace", "5" },
    { "SUPER", "6", "workspace", "6" },
    { "SUPER", "7", "workspace", "7" },
    { "SUPER", "8", "workspace", "8" },
    { "SUPER", "9", "workspace", "9" },
    { "SUPER", "0", "workspace", "10" },

    { "SUPER SHIFT", "1", "movetoworkspace", "1" },
    { "SUPER SHIFT", "2", "movetoworkspace", "2" },
    { "SUPER SHIFT", "3", "movetoworkspace", "3" },
    { "SUPER SHIFT", "4", "movetoworkspace", "4" },
    { "SUPER SHIFT", "5", "movetoworkspace", "5" },
    { "SUPER SHIFT", "6", "movetoworkspace", "6" },
    { "SUPER SHIFT", "7", "movetoworkspace", "7" },
    { "SUPER SHIFT", "8", "movetoworkspace", "8" },
    { "SUPER SHIFT", "9", "movetoworkspace", "9" },
    { "SUPER SHIFT", "0", "movetoworkspace", "10" },

    { "SUPER", "mouse_down", "workspace", "e+1" },
    { "SUPER", "mouse_up", "workspace", "e-1" },

    { "", "XF86AudioMute", "exec", "pamixer --toggle-mute" },
    { "", "XF86AudioRaiseVolume", "exec", "pamixer --increase 5" },
    { "", "XF86AudioLowerVolume", "exec", "pamixer --decrease 5" },
    { "", "XF86AudioPlay", "exec", "playerctl play-pause" },
    { "", "XF86MonBrightnessUp", "exec", "brightnessctl set +5%" },
    { "", "XF86MonBrightnessDown", "exec", "brightnessctl set 5%-" },

    { "SUPER", "grave", "togglespecialworkspace", "quake" },
    { "SUPER", "M", "movetoworkspacesilent", "special:minimized" },
    { "SUPER SHIFT", "M", "togglespecialworkspace", "minimized" },
    { "SUPER", "S", "togglespecialworkspace", "minimized" },

    { "SUPER", "Return", "exec", "waveterm" },
    { "SUPER", "T", "exec", "ghostty" },
    { "SUPER", "D", "exec", "rofi -show drun" },
    { "SUPER", "A", "exec", "rofi -show window" },
    { "SUPER", "W", "exec", "firefox" },
    { "SUPER", "E", "exec", fileManager },
    { "SUPER", "N", "exec", "dunstctl history-pop" },
    { "SUPER SHIFT", "N", "exec", "dunstctl close-all" },

    { "SUPER SHIFT", "S", "exec", "bash -c \"grim -g '$(slurp)' - | tee ~/Pictures/screenshots/$(date +%s).png\"" },
    { "SUPER SHIFT", "Print", "exec", "bash -c \"grim - | tee ~/Pictures/screenshots/$(date +%s).png\"" },
}

for _, b in ipairs(binds) do
    hl.bind(b[1], b[2], b[3], b[4])
end
