return {
  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    version = false,
    build = function()
      local TS = require("nvim-treesitter")
      if not TS.get_installed then
        LazyVim.error("Please restart Neovim and run `:TSUpdate` to use the `nvim-treesitter` **main** branch.")
        return
      end
      package.loaded["lazyvim.util.treesitter"] = nil
      LazyVim.treesitter.build(function() TS.update(nil, { summary = true }) end)
    end,
    event = { "BufReadPost", "VeryLazy" },
    cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
    opts_extend = { "ensure_installed" },
    opts = {
      indent = { enable = true },
      highlight = { enable = true },
      folds = { enable = true },
      ensure_installed = {
        "bash", "c", "diff", "html", "javascript", "jsdoc", "json", "jsonc", "lua", "luadoc", "luap",
        "markdown", "markdown_inline", "printf", "python", "query", "regex", "toml", "tsx", "typescript",
        "vim", "vimdoc", "xml", "yaml",
      },
    },
    config = function(_, opts)
      local TS = require("nvim-treesitter")
      setmetatable(require("nvim-treesitter.install"), {
        __newindex = function(_, k)
          if k == "compilers" then
            vim.schedule(function()
              LazyVim.error({
                "Setting custom compilers for `nvim-treesitter` is no longer supported.",
                "",
                "For more info, see:",
                "- [compilers](https://docs.rs/cc/latest/cc/#compile-time-requirements)",
              })
            end)
          end
        end,
      })
      if not TS.get_installed then return LazyVim.error("Please use `:Lazy` and update `nvim-treesitter`")
      elseif type(opts.ensure_installed) ~= "table" then return LazyVim.error("`nvim-treesitter` opts.ensure_installed must be a table") end
      TS.setup(opts)
      LazyVim.treesitter.get_installed(true)
      local install = vim.tbl_filter(function(lang) return not LazyVim.treesitter.have(lang) end, opts.ensure_installed or {})
      if #install > 0 then
        LazyVim.treesitter.build(function()
          TS.install(install, { summary = true }):await(function() LazyVim.treesitter.get_installed(true) end)
        end)
      end
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lazyvim_treesitter", { clear = true }),
        callback = function(ev)
          local ft, lang = ev.match, vim.treesitter.language.get_lang(ev.match)
          if not LazyVim.treesitter.have(ft) then return end
          local function enabled(feat, query)
            local f = opts[feat] or {}
            return f.enable ~= false and not (type(f.disable) == "table" and vim.tbl_contains(f.disable, lang)) and LazyVim.treesitter.have(ft, query)
          end
          if enabled("highlight", "highlights") then pcall(vim.treesitter.start, ev.buf) end
          if enabled("indent", "indents") then LazyVim.set_default("indentexpr", "v:lua.LazyVim.treesitter.indentexpr()") end
          if enabled("folds", "folds") then
            if LazyVim.set_default("foldmethod", "expr") then LazyVim.set_default("foldexpr", "v:lua.LazyVim.treesitter.foldexpr()") end
          end
        end,
      })
    end,
  },

  -- Treesitter Text Objects
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = "VeryLazy",
    opts = {
      move = {
        enable = true,
        set_jumps = true,
        keys = {
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
        },
      },
    },
    config = function(_, opts)
      local TS = require("nvim-treesitter-textobjects")
      if not TS.setup then
        LazyVim.error("Please restart Neovim and run `:Lazy` and update `nvim-treesitter`")
        return
      end
      TS.setup(opts)
      local function attach(buf)
        local ft = vim.bo[buf].filetype
        if not (vim.tbl_get(opts, "move", "enable") and LazyVim.treesitter.have(ft, "textobjects")) then return end
        local moves = vim.tbl_get(opts, "move", "keys") or {}
        for method, keymaps in pairs(moves) do
          for key, query in pairs(keymaps) do
            local queries = type(query) == "table" and query or { query }
            local parts = {}
            for _, q in ipairs(queries) do
              local part = q:gsub("@", ""):gsub("%..*", "")
              part = part:sub(1, 1):upper() .. part:sub(2)
              table.insert(parts, part)
            end
            local desc = table.concat(parts, " or ")
            desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
            desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
            if not (vim.wo.diff and key:find("[cC]")) then
              vim.keymap.set({ "n", "x", "o" }, key, function()
                require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
              end, { buffer = buf, desc = desc, silent = true })
            end
          end
        end
      end
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lazyvim_treesitter_textobjects", { clear = true }),
        callback = function(ev) attach(ev.buf) end,
      })
      vim.tbl_map(attach, vim.api.nvim_list_bufs())
    end,
  },

  -- Autotag
  {
    "windwp/nvim-ts-autotag",
    event = "BufReadPost",
    opts = {},
  },
}
