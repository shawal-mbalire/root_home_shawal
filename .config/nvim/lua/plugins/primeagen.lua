return {
    {
        "ThePrimeagen/rfceez",
        config = function()
            local rfc = require("rfceez")
            rfc.setup()
            vim.keymap.set("n", "<leader>ra", function() rfc.add() end)
            vim.keymap.set("n", "<leader>rd", function() rfc.rm() end)
            vim.keymap.set("n", "<leader>rs", function() rfc.show_notes() end)
            vim.keymap.set("n", "[r", function() rfc.nav_next() end)
            vim.keymap.set("n", "[[r", function() rfc.show_next() end)
        end
    },
    {
        "ThePrimeagen/harpoon",
        config = function()
            local harpoon = require("harpoon")
            harpoon.setup()

            vim.keymap.set("n", "<leader>A", function() harpoon.mark.prepend_file() end)
            vim.keymap.set("n", "<leader>a", function() harpoon.mark.add_file() end)
            vim.keymap.set("n", "<C-e>", function() harpoon.ui.toggle_quick_menu() end)

            vim.keymap.set("n", "<C-h>", function() harpoon.ui.nav_file(1) end)
            vim.keymap.set("n", "<C-t>", function() harpoon.ui.nav_file(2) end)
            vim.keymap.set("n", "<C-n>", function() harpoon.ui.nav_file(3) end)
            vim.keymap.set("n", "<C-s>", function() harpoon.ui.nav_file(4) end)
            vim.keymap.set("n", "<leader><C-h>", function() harpoon.mark.set_index(1) end)
            vim.keymap.set("n", "<leader><C-t>", function() harpoon.mark.set_index(2) end)
            vim.keymap.set("n", "<leader><C-n>", function() harpoon.mark.set_index(3) end)
            vim.keymap.set("n", "<leader><C-s>", function() harpoon.mark.set_index(4) end)
        end
    },
    {
        "ThePrimeagen/vim-apm",
        config = function()
            --[[
            local apm = require("vim-apm")

            apm.setup({})
            vim.keymap.set("n", "<leader>apm", function() apm.toggle_monitor() end)
            --]]
        end
    },
    {
        "ThePrimeagen/vim-with-me",
        config = function() end
    },
}
