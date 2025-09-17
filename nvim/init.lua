local vim = vim
local map = vim.keymap.set
local o = vim.opt

o.expandtab = true
o.mousemoveevent = true
o.relativenumber = true
o.number = true
o.smartindent = true
o.ignorecase = true
o.undofile = true
o.incsearch = true
o.cursorcolumn = false
o.swapfile = false
o.wrap = false
o.tabstop = 2
o.shiftwidth = 2
o.winborder = "rounded"
o.signcolumn = "yes"

vim.g.mapleader = " "

map("n", "<leader>o", ":update<CR> :source<CR>", { desc = "Write and source config" })
map("n", "<leader>q", ":write<CR> :quit<CR>", { desc = "Write and Quit" })
map("n", "<leader>o", ":update<CR> :source<CR>", { desc = "Write and Source the current file" })
map("n", "<leader>w", ":write<CR>", { desc = "Write" })
map({ "n", "v", "x" }, "<leader>y", '"+y<CR>', { desc = "Copy to system clipboard" })
map({ "n", "v", "x" }, "<leader>d", '"+d<CR>', { desc = "Delete and copy to system clipboard" })
map({ "n", "v", "x" }, "<leader>p", '"+p<CR>', { desc = "Paste from System Clipboard" })
map({ "n", "v", "x" }, "<leader>s", ":e #<CR>", { desc = "Open Alternate File" })
map({ "n", "v", "x" }, "<leader>S", ":sf #<CR>", { desc = "Open Alternate File in Split" })
map("n", "#", "$", { noremap = true, silent = true })
map("n", ";", ":", { noremap = true })
map("v", ";", ":", { noremap = true })
map("n", "<leader>e", "<Cmd>Neotree toggle left<CR>", { desc = "Explorer NeoTree" })
map("n", "<leader>lf", vim.lsp.buf.format)
map("n", "<C-h>", ":TmuxNavigateLeft<CR>", { desc = "Go to left window" })
map("n", "<C-j>", ":TmuxNavigateDown<CR>", { desc = "Go to down window" })
map("n", "<C-k>", ":TmuxNavigateUp<CR>", { desc = "Go to up window" })
map("n", "<C-l>", ":TmuxNavigateRight<CR>", { desc = "Go to right window" })

vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-mini/mini.comment" },
	{ src = "https://github.com/nvim-mini/mini.surround" },
	{ src = "https://github.com/nvim-mini/mini.indentscope" },
	{ src = "https://github.com/nvim-mini/mini.pairs" },
	{ src = "https://github.com/nvim-mini/mini.clue" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
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
	{ src = "https://github.com/derektata/lorem.nvim" },
	{ src = "https://github.com/3rd/image.nvim" },
	{ src = "https://github.com/folke/noice.nvim" },
	{ src = "https://github.com/natecraddock/workspaces.nvim" },
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
	"css_variables",
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
require("image").setup()
require("noice").setup({
	lsp = {
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
		},
	},
})

require("workspaces").setup({
	hooks = {
		open = { "Telescope find_files" },
	},
})

require("lorem").opts({
	sentence_length = "mixed",
	comma_chance = 0.3,
	max_commas = 2,
	debounce_ms = 200,
})

local builtin = require("telescope.builtin")
map("n", "<leader>f", builtin.find_files, { desc = "Open File Selector" })
map("n", "<leader>b", builtin.buffers, { desc = "Open Buffer Selector" })
map("n", "<leader>rg", builtin.live_grep, { desc = "Open Grep Selector" })
map("n", "<leader>h", builtin.help_tags, { desc = "Open Help Selector" })
map("n", "<leader>th", builtin.colorscheme, { desc = "Open Colorscheme Selector" })
map("n", "<leader>w", ":Telescope workspaces<CR>", { desc = "Open Workspace Selector" })
map("n", "<leader>bb", builtin.builtin, { desc = "Open Builtin Selector" })

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
	window = {
		["P"] = {
			"toggle-preview",
			config = {
				use_float = true,
				use_image_nvim = true,
			},
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

local miniclue = require("mini.clue")
miniclue.setup({
	triggers = {
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },
		{ mode = "i", keys = "<C-x>" },
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },
		{ mode = "n", keys = "'" },
		{ mode = "n", keys = "`" },
		{ mode = "x", keys = "'" },
		{ mode = "x", keys = "`" },
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		{ mode = "i", keys = "<C-r>" },
		{ mode = "c", keys = "<C-r>" },
		{ mode = "n", keys = "<C-w>" },
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },
	},

	clues = {
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),
	},
})
require("mini.surround").setup()
require("mini.pairs").setup()
require("mini.indentscope").setup()
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
		javascriptreact = { "prettierd", "prettier" },
		typescriptreact = { "prettierd", "prettier" },
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
