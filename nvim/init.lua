local vim = vim
local map = vim.keymap.set
vim.o.expandtab = true
vim.o.mousemoveevent = true
vim.o.relativenumber = true
vim.o.number = true
vim.o.smartindent = true
vim.o.ignorecase = true
vim.o.undofile = true
vim.o.incsearch = true
vim.o.cursorcolumn = false
vim.o.swapfile = false
vim.o.wrap = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.winborder = "rounded"
vim.o.signcolumn = "yes"

vim.g.mapleader = " "

map("n", "<leader>o", ":update<CR> :source<CR>", { desc = "Write and source config" })
map("n", "<leader>w", ":write<CR>", { desc = "Write File" })
map("n", "<leader>q", ":quit<CR>")
map("n", "<leader>o", ":update<CR> :source<CR>")
map("n", "<leader>w", ":write<CR>")
map({ "n", "v", "x" }, "<leader>y", '"+y<CR>')
map({ "n", "v", "x" }, "<leader>d", '"+d<CR>')
map({ "n", "v", "x" }, "<leader>p", '"+p<CR>')
map({ "n", "v", "x" }, "<leader>s", ":e #<CR>")
map({ "n", "v", "x" }, "<leader>S", ":sf #<CR>")
map("n", "#", "$", { noremap = true, silent = true })
map("n", ";", ":", { noremap = true })
map("v", ";", ":", { noremap = true })
map("n", "<leader>e", "<Cmd>Neotree toggle left<CR>", { desc = "Explorer NeoTree" })
map("n", "<leader>lf", vim.lsp.buf.format)
map("n", "<C-h>", ":TmuxNavigateLeft<CR>")
map("n", "<C-j>", ":TmuxNavigateDown<CR>")
map("n", "<C-k>", ":TmuxNavigateUp<CR>")
map("n", "<C-l>", ":TmuxNavigateRight<CR>")

vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-mini/mini.comment" },
	{ src = "https://github.com/nvim-mini/mini.surround" },
	-- { src = "https://github.com/nvim-mini/mini.statusline" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/windwp/nvim-autopairs" },
	{ src = "https://github.com/folke/lazydev.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/HiPhish/rainbow-delimiters.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/Saghen/blink.cmp" },
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
	{ src = "https://github.com/windwp/nvim-ts-autotag" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-neo-tree/neo-tree.nvim", version = vim.version.range("3") },
	{ src = "https://github.com/goolord/alpha-nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/rcarriga/nvim-notify" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/RRethy/base16-nvim" },
	{ src = "https://github.com/akinsho/bufferline.nvim" },
})

vim.lsp.enable({
	"lua_ls",
	"ts_ls",
	"marksman",
	"clangd",
	"tailwindcss",
	"gopls",
	"rust_analyzer",
	"html",
})

local ok, notify = pcall(require, "notify")
if not ok then
	return
end

notify.setup({
	stages = "fade_in_slide_out",
	timeout = 3000,
	fps = 60,
	render = "default",
	background_colour = "#1e1e1e",
	max_width = 80,
	max_height = 20,
	level = "info",
	icons = {
		ERROR = "",
		WARN = "",
		INFO = "",
		DEBUG = "",
		TRACE = "✎",
	},
})

-- Transparent background (Catppuccin friendly)
vim.cmd("highlight NotifyBackground guibg=NONE")

-- Override default notify
vim.notify = notify

-- Integrate with LSP messages (progress, etc.)
local lsp_util = vim.lsp.util
lsp_util._original_notify = lsp_util._original_notify or vim.notify
vim.lsp.util.show_line_diagnostics = function(...)
	vim.notify = notify
	return lsp_util._original_notify(...)
end

-- Hook :messages into telescope with notify history
pcall(function()
	require("telescope").load_extension("notify")
end)

-- Example keymap: open notification history
vim.keymap.set("n", "<leader>un", function()
	require("telescope").extensions.notify.notify()
end, { desc = "Show Notifications" })

local dashboard = require("alpha.themes.dashboard")
dashboard.section.buttons.val = {
	dashboard.button("SPC f", "  Find Files", ":Telescope find_files<CR>"),
	dashboard.button("SPC e", "  File Explorer", ":Neotree toggle<CR>"),
	dashboard.button("SPC r", "  Recent Files", ":Pick oldfiles<CR>"),
	dashboard.button("q", "  Quit", ":qa<CR>"),
}
require("alpha").setup(dashboard.config)

local builtin = require("telescope.builtin")
map("n", "<leader>f", builtin.find_files)
map("n", "<leader>b", builtin.buffers)
map("n", "<leader>rg", builtin.live_grep)
map("n", "<leader>rf", builtin.oldfiles)
map("n", "<leader>h", builtin.help_tags)
map("n", "<leader>th", builtin.colorscheme)
map("n", "<leader>wd", builtin.diagnostics)
map("n", "<leader>bb", builtin.builtin)

require("bufferline").setup({
	options = {
		separator_style = "│",
		diagnostics = "nvim_lsp",
		diagnostics_indicator = function(count, level)
			local icon = level:match("error") and " " or " "
			return " " .. icon .. count
		end,
		offsets = {
			{
				filetype = "neo-tree",
				text = "File Explorer",
				highlight = "Directory",
				separator = true, -- use a "true" to enable the default, or set your own character
			},
		},
	},
})

map("n", "<Tab>", ":BufferLineCycleNext<CR>")
map("n", "<S-Tab>", ":BufferLineCycleNext<CR>")
vim.cmd([[
  hi BufferLineFill              guibg=NONE
  hi BufferLineBackground        guibg=NONE
  hi BufferLineTab               guibg=NONE
  hi BufferLineTabSelected       guibg=NONE
  hi BufferLineTabClose          guibg=NONE
  hi BufferLineCloseButton       guibg=NONE
  hi BufferLineCloseButtonVisible guibg=NONE
  hi BufferLineCloseButtonSelected guibg=NONE
  hi BufferLineBufferSelected    guibg=NONE gui=bold
  hi BufferLineModified          guibg=NONE
  hi BufferLineModifiedSelected  guibg=NONE
  hi BufferLineSeparator         guibg=NONE guifg=NONE
  hi BufferLineSeparatorVisible  guibg=NONE guifg=NONE
  hi BufferLineSeparatorSelected guibg=NONE guifg=NONE
  hi BufferLineOffsetSeparator   guibg=NONE guifg=NONE
]])
require("neo-tree").setup({
	close_if_last_window = true,
	source_selector = {
		winbar = false,
		statusline = false,
		truncation_character = "",
	},
	filesystem = {
		hijack_netrw_behavior = "open_default",
		bind_to_cwd = false,
		follow_current_file = { enabled = true },
	},
	default_component_configs = {
		name = {
			use_git_status_colors = true,
		},
		root_name = {
			enabled = false,
		},
	},
})
require("lualine").setup({
	options = {
		theme = "catppuccin",
		section_separator = "",
		components_separator = "",
		icons_enabled = true,
	},
	dependencies = { "nvim-tree/nvim-web-devicons " },
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "filename" },
		lualine_c = { "" },
		lualine_x = { "filetype" },
		lualine_y = { "" },
		lualine_z = { "" },
	},
})
require("mason").setup()
require("lazydev").setup()
require("mini.surround").setup()

require("mini.comment").setup({
	mappings = {
		comment_line = "<leader>/",
		comment_visual = "<leader>/",
	},
})
require("blink-cmp").setup({
	completion = {
		trigger = {
			show_on_keyword = true,
		},
	},
	keymap = {
		["<Tab>"] = { "select_next", "fallback" },
		["<S-Tab>"] = { "select_prev", "fallback" },
		["<CR>"] = { "accept", "fallback" },
	},
})

require("nvim-autopairs").setup()

require("lspconfig").ts_ls.setup({
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_dir = function()
		return vim.loop.cwd()
	end,
})

require("lspconfig").solidity.setup({
	cmd = { "solidity-language-server", "--stdio" },
	filetypes = { "solidity" },
	root_dir = require("lspconfig.util").root_pattern("hardhat.config.js", "truffle-config.js", ".git"),
})

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "prettierd", "prettier" },
		typescript = { "prettierd", "prettier" },
		python = { "black" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		html = { "superhtml" },
		sh = { "shfmt" },
	},
})

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

require("render-markdown").setup({
	completions = { lsp = { enabled = true } },
})

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"cpp",
		"c",
		"typescript",
		"javascript",
		"markdown",
		"yaml",
		"latex",
		"markdown_inline",
		"rust",
		"go",
		"html",
		"css",
		"regex",
		"bash",
	},
})
require("render-markdown").setup({ latex = { enabled = false } })

require("nvim-ts-autotag").setup({
	opts = {
		enable_close = true,
		enable_rename = true,
		enable_close_on_slash = false,
	},
})

require("catppuccin").setup({
	transparent_background = true,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight Text when yanking",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		require("vim.treesitter").start(bufnr, "markdown")
	end,
})

vim.cmd("colorscheme catppuccin")
vim.api.nvim_set_hl(0, "telescopenormal", { bg = "none" })
vim.api.nvim_set_hl(0, "telescopeborder", { bg = "none" })
vim.api.nvim_set_hl(0, "telescopepromptnormal", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { bg = "none" })
