return {
  {
    "folke/snacks.nvim",
    opts = {
      explorer = { enabled = false, replace_netrw = false },
    },
    keys = {
      { "<leader>e", function() require("mini.files").open(vim.uv.cwd(), true) end, desc = "MiniFiles (cwd)" },
    },
  },
}
