-- Input device configuration
local v = require("modules.variables")

hl.config({
  input = {
    kb_layout = v.kb_layout,
    kb_variant = "",
    kb_model = "",
    kb_options = "caps:swapescape, grp:win_space_toggle",
    kb_rules = "",
    follow_mouse = 1,
    sensitivity = v.mouse_sensitivity,
    touchpad = {
      natural_scroll = v.touchpad_natural_scroll,
    },
  },
})

hl.device({
  name = "epic-mouse-v1",
  sensitivity = v.device_sensitivity,
})