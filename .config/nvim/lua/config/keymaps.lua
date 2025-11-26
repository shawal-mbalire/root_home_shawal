-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Override to open in cwd
vim.keymap.set("n", "<leader>ff", function() Snacks.picker.files({ cwd = vim.fn.getcwd() }) end, { desc = "Find Files (cwd)" })
vim.keymap.set("n", "<leader>sg", function() Snacks.picker.grep({ cwd = vim.fn.getcwd() }) end, { desc = "Grep (cwd)" })
vim.keymap.set("n", "<leader>sb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>ft", function() Snacks.terminal(nil, { cwd = vim.fn.getcwd() }) end, { desc = "Terminal (cwd)" })
vim.keymap.set("n", "<leader>e", function() Snacks.explorer({ cwd = vim.fn.getcwd() }) end, { desc = "Explorer Snacks (cwd)" })

-- Tmux integration
vim.keymap.set("n", "<leader>tn", "<cmd>!tmux new-window<cr>", { desc = "New Tmux Window" })
vim.keymap.set("n", "<leader>ts", "<cmd>!tmux split-window<cr>", { desc = "Split Tmux Window" })
vim.keymap.set("n", "<leader>tv", "<cmd>!tmux split-window -h<cr>", { desc = "Vertical Split Tmux" })
