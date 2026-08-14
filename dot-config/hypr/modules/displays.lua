-- Monitor configuration
hl.monitor({
  output = "eDP-1",
  mode = "1920x1200@60",
  position = "0x0",
  scale = 1,
})

hl.monitor({
  output = "HDMI-A-2",
  mode = "highres",
  position = "0x0",
  scale = 1,
  mirror = "eDP-1",
})