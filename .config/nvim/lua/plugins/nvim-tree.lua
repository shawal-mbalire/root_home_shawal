return {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    config = function()
        -- disable netrw at the very start of your init.lua
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        -- settings
        local nvim_tree = require("nvim-tree")
        nvim_tree.setup({
            sort = {
                sorter = "case_sensitive",
            },
            view = {
                width = 30,
                side = "right",
            },
            renderer = {
                group_empty = true,
            },
            filters = {
                dotfiles = false,
                git_ignored = false,
            },
        })

        local nvim_tree_api = require("nvim-tree.api")
        --  key bindings
        -- vim.keymap.set("n", "<leader>t", function() nvim_tree_api.tree.toggle() end)
        -- vim.keymap.set("n", "<leader>t", function() nvim_tree_api.tree.close_in_this_tab() end)
        vim.keymap.set("n", "<leader>t", function() nvim_tree_api.tree.open() end)
    end,
}
