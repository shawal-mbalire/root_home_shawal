-- Hyprland Lua Configuration (Laptop variant)
-- Entry point: sources all modules with laptop-specific overrides

local v = require("modules.variables")

-- Laptop-specific overrides
v.active_border_color = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 180 }
v.inactive_border_color = "rgba(595959aa)"
v.gaps_in = 4
v.gaps_out = 5
v.rounding = 5
v.kb_layout = "gb,ara"

-- Source all modules (laptop uses displays-laptop instead of displays)
require("modules.displays-laptop")
require("modules.autostart")
require("modules.env")
require("modules.look")
require("modules.input")
require("modules.keybindings")
require("modules.windows")