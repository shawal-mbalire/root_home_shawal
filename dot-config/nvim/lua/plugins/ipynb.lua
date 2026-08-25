return {
	-- 1. Parse .ipynb JSON into human-readable Markdown dynamically
	{
		"GCBallesteros/jupytext.nvim",
		lazy = false,
		opts = {
			style = "markdown",
			output_extension = "md",
			force_ft = "markdown",
		},
	},

	-- 2. Kernel Client (ZeroMQ socket communication)
	{
		"benlubas/molten-nvim",
		version = "^1.0.0",
		build = ":UpdateRemotePlugins",
		ft = { "markdown", "python" },
		init = function()
			-- General settings
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_output_win_max_height = 20
			vim.g.molten_auto_open_output = false
			vim.g.molten_wrap_output = true
			vim.g.molten_virt_text_output = true
			vim.g.molten_virt_lines_off_by_1 = true

			-- Automatically start the kernel when an .ipynb file is opened
			vim.api.nvim_create_autocmd("BufReadPost", {
				pattern = "*.ipynb",
				callback = function()
					vim.cmd("MoltenInit python3")
				end,
			})
		end,
		keys = {
			{ "<leader>me", ":MoltenEvaluateOperator<CR>", desc = "Evaluate Operator" },
			{ "<leader>rl", ":MoltenEvaluateLine<CR>", desc = "Evaluate Line" },
			{ "<leader>rc", ":MoltenReevaluateCell<CR>", desc = "Re-evaluate Cell" },
			{ "<leader>rd", ":MoltenDelete<CR>", desc = "Delete Molten Cell" },
			{ "<leader>os", ":MoltenShowOutput<CR>", desc = "Show Molten Output" },
			{ "<leader>oh", ":MoltenHideOutput<CR>", desc = "Hide Molten Output" },
		},
	},

	-- 3. High-resolution inline graphics for Kitty / Ghostty
	{
		"3rd/image.nvim",
		opts = {
			backend = "kitty", -- Kitty Graphics Protocol (works natively in Kitty and Ghostty)
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "markdown", "quarto" },
				},
			},
			max_width = 100,
			max_height = 15,
			max_height_window_percentage = 50,
			window_overlap_clear_target = true,
		},
	},

	-- 4. In-memory virtual LSP for Python code blocks embedded in Markdown
	{
		"jmbuhr/otter.nvim",
		dependencies = { "neovim/nvim-lspconfig" },
		opts = {
			buffers = { set_filetype = true },
		},
		config = function(_, opts)
			local otter = require("otter")
			otter.setup(opts)

			-- Activate Otter LSP inside Markdown buffers generated from .ipynb files
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "markdown",
				callback = function()
					otter.activate({ "python" }, true, true, nil)
				end,
			})
		end,
	},
}
