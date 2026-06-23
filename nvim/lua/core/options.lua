-- Neovim Options Configuration
-- Location: ~/.config/nvim/lua/core/options.lua

local set = vim.opt

-- Editor behavior
set.expandtab = true
set.tabstop = 2
set.shiftwidth = 2
set.smartindent = true
set.smarttab = true
set.wrap = false
set.swapfile = false
set.writebackup = false
set.backup = false
set.undofile = true
set.autoread = true
set.cmdheight = 0
set.iskeyword:append("-")
set.path:append("**")

-- Window behavior
set.splitright = true
set.scrolloff = 10
set.cmdheight = 0

-- Grep
set.grepprg = "rg --vimgrep"
set.grepformat = "%f:%l:%c:%m"

-- Line numbers
set.number = true
set.relativenumber = true
set.signcolumn = "yes"
set.cursorcolumn = false

-- Diagnostics
vim.diagnostic.config({
	virtual_text = {
		prefix = "●",
		spacing = 2,
	},
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = { border = "rounded" },
})

-- Search
set.ignorecase = true
set.smartcase = true
set.hlsearch = true
set.incsearch = true
set.inccommand = "split"
set.laststatus = 3

-- Performance
set.mousemoveevent = true
set.updatetime = 500
set.timeoutlen = 400

-- List Chars
set.list = true
set.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

require("vim._core.ui2").enable({})
