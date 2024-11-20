vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

vim.opt.guicursor = ""
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

vim.opt.number = true                    -- Show line numbers
vim.opt.relativenumber = true            -- Show relative line numbers
vim.opt.wrap = false                      -- Wrap lines
vim.opt.encoding = "utf-8"               -- Set encoding to UTF-8
vim.opt.fileencoding = "utf-8"           -- Set file encoding to UTF-8
vim.opt.fileencodings = "utf-8"          -- Fallback encodings
vim.opt.ttyfast = true                   -- Faster rendering for better performance
vim.opt.mouse = ""

vim.opt.wildmenu = true                  -- Visual autocomplete for command menu
vim.opt.lazyredraw = true                -- Redraw screen only when needed
vim.opt.showmatch = true                 -- Highlight matching parentheses/brackets
vim.opt.laststatus = 2                   -- Always show status line
vim.opt.ruler = true                     -- Show cursor position in status line
vim.opt.visualbell = true                -- Blink cursor on error

-- Tab and indentation settings
vim.opt.tabstop = 4                      -- Width of a <TAB> character
vim.opt.expandtab = true                 -- Convert <TAB> key-presses to spaces
vim.opt.shiftwidth = 4                   -- Number of spaces for each (auto)indent
vim.opt.softtabstop = 4                  -- Number of spaces when backspacing over tabs
vim.opt.autoindent = true                -- Copy indent from the current line when starting a new line
vim.opt.smartindent = true               -- Auto-indent after '{'

-- Search settings
vim.opt.incsearch = true                 -- Incremental search
vim.opt.hlsearch = true                  -- Highlight search matches
vim.opt.ignorecase = true                -- Ignore case in search

-- File handling
vim.opt.autoread = true                  -- Auto-reload files modified outside of Vim

-- General settings
vim.opt.compatible = false               -- Disable compatibility mode
vim.opt.cursorline = true                -- Highlight the current line
vim.opt.cursorcolumn = true              -- Highlight the current column
vim.opt.showcmd = true                   -- Show the command in the last line of the screen
vim.opt.showmode = true                  -- Display current mode (insert, replace, etc.)
vim.opt.history = 1000                   -- Keep a history of commands

-- Wildmenu settings
vim.opt.wildmenu = true                  -- Enable autocomplete menu after pressing TAB
vim.opt.wildmode = {"list", "longest"}   -- Wildmenu behaves similar to Bash completion
vim.opt.wildignore = "*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx"
