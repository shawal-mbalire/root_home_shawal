return {
  -- LSP Config
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = { "mason-lspconfig.nvim", "LazyVim/LazyVim" },
    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
          },
        },
      },
      inlay_hints = { enabled = false },
      codelens = { enabled = false },
      capabilities = {
        workspace = {
          fileOperations = {
            didRename = true,
            willRename = true,
          },
        },
      },
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
      servers = {
        lua_ls = {
          settings = {
            Lua = {
              workspace = { checkThirdParty = false },
              codeLens = { enable = true },
              completion = { callSnippet = "Replace" },
              doc = { privateName = { "^_" } },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },
      },
      setup = {},
    },
    config = function(_, opts)
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local buffer = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
        end,
      })
    end,
  },

  -- Mason LSP Integration
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    lazy = true,
    opts = function()
      local ensure_installed = {
        "lua_ls",
        "tsserver",
        "html",
        "cssls",
        "emmet_ls",
        "pyright",
        "bashls",
        "jsonls",
        "yamlls",
      }
      return {
        ensure_installed = ensure_installed,
        handlers = {
          function(server)
            local lspconfig_opts = LazyVim.opts("nvim-lspconfig")
            local server_opts = lspconfig_opts.servers and lspconfig_opts.servers[server] or {}
            if lspconfig_opts.setup and lspconfig_opts.setup[server] then
               if lspconfig_opts.setup[server](server, server_opts) then return end
            elseif lspconfig_opts.setup and lspconfig_opts.setup["*"] then
               if lspconfig_opts.setup["*"](server, server_opts) then return end
            end
            require("lspconfig")[server].setup(server_opts)
          end,
        },
      }
    end,
  },

  -- Mason
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts_extend = { "ensure_installed" },
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      mr:on("package:install:success", function()
        vim.defer_fn(function()
          require("lazy.core.handler.event").trigger({
            event = "FileType",
            buf = vim.api.nvim_get_current_buf(),
          })
        end, 100)
      end)
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed or {}) do
          local p = mr.get_package(tool)
          if not p:is_installed() then p:install() end
        end
      end)
    end,
  },

  -- LazyDev
  {
    "folke/lazydev.nvim",
    ft = "lua",
    cmd = "LazyDev",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "LazyVim", words = { "LazyVim" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { path = "lazy.nvim", words = { "LazyVim" } },
      },
    },
  },

  -- Plenary
  { "nvim-lua/plenary.nvim", lazy = true },
}
