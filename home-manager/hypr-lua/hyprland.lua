-- Hyprland Lua Configuration
-- Main entry point

-- Add the current directory to the package path for require
package.path = package.path .. ";/home/death916/.config/hypr/lua/?.lua"

-- Utility to get hostname
local function get_hostname()
    local f = io.popen("hostname")
    local hostname = f:read("*a")
    f:close()
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
