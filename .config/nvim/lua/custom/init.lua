vim.opt.colorcolumn = "80"

-- Set tabline highlight groups to semi-transparent with a subtle background
vim.api.nvim_set_hl(0, "TabLine", { bg = "#1e1e1e", blend = 80 })
vim.api.nvim_set_hl(0, "TabLineSel", { bg = "#282828", blend = 80 })
vim.api.nvim_set_hl(0, "TabLineFill", { bg = "#1e1e1e", blend = 80 })
