-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.autoread = true
vim.opt.updatetime = 200

-- Workaround for Neovim 0.12.5 bug: vim.fs.abspath asserts uv.cwd() ~= nil
-- but uv.cwd() can return nil during BufNewFile autocommands
local uv = vim.uv or vim.loop
local orig_abspath = vim.fs.abspath
vim.fs.abspath = function(path, opts)
  local ok, result = pcall(orig_abspath, path, opts)
  if ok then
    return result
  end
  -- Fallback: if cwd is nil, return the path as-is (or try to handle gracefully)
  if type(path) == "string" then
    return path
  end
  error(result)
end
