-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Disable LSP virtual text to reduce clutter
vim.diagnostic.config({
  virtual_text = false, -- Disables the inline text
  signs = false,        -- Disables icons in the left column
  underline = false,    -- Disables underline under errors
  update_in_insert = false,
})

-- Map 'gl' to show diagnostic in floating window
vim.keymap.set('n', 'gl', vim.diagnostic.open_float)

-- Toggle virtual text on/off
vim.keymap.set('n', '<leader>td', function()
  local config = vim.diagnostic.config()
  vim.diagnostic.config({ virtual_text = not config.virtual_text })
end)