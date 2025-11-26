-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Override to open in cwd
vim.keymap.set("n", "<leader>ff", function() Snacks.picker.files({ cwd = vim.fn.getcwd() }) end, { desc = "Find Files (cwd)" })
vim.keymap.set("n", "<leader>ft", function() Snacks.terminal(nil, { cwd = vim.fn.getcwd() }) end, { desc = "Terminal (cwd)" })
vim.keymap.set("n", "<leader>e", function() Snacks.explorer({ cwd = vim.fn.getcwd() }) end, { desc = "Explorer Snacks (cwd)" })
