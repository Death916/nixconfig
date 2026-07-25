-- Keybindings

local fileManager = "nautilus"

-- Core Window Management
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("hyprlock"))

-- Focus Movement
hl.bind("SUPER + left",  hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up",    hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down",  hl.dsp.focus({ direction = "down" }))

-- Move Window
hl.bind("SUPER + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Resize Window
hl.bind("SUPER + CTRL + left",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive -40 0"))
hl.bind("SUPER + CTRL + right", hl.dsp.exec_cmd("hyprctl dispatch resizeactive 40 0"))
hl.bind("SUPER + CTRL + up",    hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 -40"))
hl.bind("SUPER + CTRL + down",  hl.dsp.exec_cmd("hyprctl dispatch resizeactive 0 40"))

-- Workspaces 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind("SUPER + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Special Workspaces
hl.bind("SUPER + grave",         hl.dsp.workspace.toggle_special("quake"))
hl.bind("SUPER + M",             hl.dsp.window.move({ workspace = "special:minimized", silent = true }))
hl.bind("SUPER + SHIFT + M",     hl.dsp.workspace.toggle_special("minimized"))
hl.bind("SUPER + S",             hl.dsp.workspace.toggle_special("minimized"))

-- Application Launchers
hl.bind("SUPER + Return",  hl.dsp.exec_cmd("waveterm"))
hl.bind("SUPER + T",       hl.dsp.exec_cmd("ghostty"))
hl.bind("SUPER + D",       hl.dsp.exec_cmd("rofi -show drun"))
hl.bind("SUPER + A",       hl.dsp.exec_cmd("rofi -show window"))
hl.bind("SUPER + W",       hl.dsp.exec_cmd("firefox"))
hl.bind("SUPER + E",       hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + N",       hl.dsp.exec_cmd("dunstctl history-pop"))
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("dunstctl close-all"))

-- Screenshots
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd([[bash -c "grim -g '$(slurp)' - | tee ~/Pictures/screenshots/$(date +%s).png"]]))
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd([[bash -c "grim - | tee ~/Pictures/screenshots/$(date +%s).png"]]))

-- Hardware / Media Keys
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pamixer --toggle-mute"), { locked = true, repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer --increase 5"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer --decrease 5"),  { locked = true, repeating = true })
hl.bind("XF86AudioPlay",        hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
