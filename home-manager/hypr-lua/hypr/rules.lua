-- Rules: Window and Workspace

-- Workspace Rules
if _G.HOSTNAME == "death-pc" then
    hl.workspace_rule({ workspace = "1", monitor = "desc:BNQ BenQ EL2870U 26M05467SL0" })
    hl.workspace_rule({ workspace = "2", monitor = "desc:Acer Technologies R240HY T4BAA0012400" })
    hl.workspace_rule({ workspace = "3", monitor = "desc:WAM U24C 0000000000001" })
end

-- Window Rules
local window_rules = {
    {
        match = { class = "^(Wave|waveterm)$" },
        workspace = "special:quake",
        float = true,
        size = "80% 80%",
        center = true
    },
    {
        match = { floating = true },
        opacity = "0.5"
    },
    {
        match = { floating = false },
        opacity = "0.8"
    },
    {
        match = { fullscreen = true },
        opacity = "1.0",
        idle_inhibit = "fullscreen"
    },
    {
        match = { class = "^(vlc)$" },
        opacity = "1.0 override 1.0 override"
    },
    {
        match = { class = "^(jellyfinmediaplayer)$" },
        opacity = "1.0 override 1.0 override"
    },
    {
        match = { title = "^(Picture-in-Picture)$" },
        float = true
    },
    {
        match = { class = "^(confirm)$" },
        float = true
    },
    {
        match = { class = "^(dialog)$" },
        float = true
    },
    {
        match = { class = "^(file_progress)$" },
        float = true
    },
    {
        match = { class = "^(confirmreset)$" },
        float = true
    },
    {
        match = { class = "^(makeinput)$" },
        float = true
    },
    {
        match = { class = "^(download)$" },
        float = true
    },
    {
        match = { class = "^(notification)$" },
        float = true
    },
    {
        match = { class = "^(error)$" },
        float = true
    },
    {
        match = { class = "^(pinentry)$" },
        float = true
    },
    {
        match = { class = "^(ssh-askpass)$" },
        float = true
    },
    {
        match = { class = "^(lxpolkit)$" },
        float = true
    },
    {
        match = { class = "^(thunar)$" },
        float = true
    },
    {
        match = { class = "^(pavucontrol)$" },
        float = true
    },
    {
        match = { class = "^(blueman-applet)$" },
        float = true
    },
    {
        match = { class = "^(nm-applet)$" },
        float = true,
        no_initial_focus = true
    },
    {
        match = { class = "^(blueman-applet)$" },
        no_initial_focus = true
    },
}

for _, r in ipairs(window_rules) do
    hl.window_rule(r)
end
