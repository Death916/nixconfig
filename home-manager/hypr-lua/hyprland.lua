-- Hyprland Lua Configuration
-- Main entry point

-- Add config directory to package.path for require
package.path = package.path .. ";/home/death916/.config/hypr/?.lua"

-- Utility to get hostname
local function get_hostname()
    local f = io.popen("hostname")
    local hostname = f and f:read("*a") or ""
    if f then f:close() end
    return hostname:gsub("%s+", "")
end

_G.HOSTNAME = get_hostname()

-- Import modules
require("hypr.env")
require("hypr.monitors")
require("hypr.settings")
require("hypr.rules")
require("hypr.binds")
require("hypr.autostart")
