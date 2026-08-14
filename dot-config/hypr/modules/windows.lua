-- Window and workspace rules
local v = require("modules.variables")

-- Blur waybar layer
hl.layer_rule({
  match = { namespace = "waybar" },
  blur = true,
})