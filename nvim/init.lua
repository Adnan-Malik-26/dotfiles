-- ============================================================================
-- Neovim Configuration
-- ============================================================================

local vim = vim
local api = vim.api
local map = vim.keymap.set
local opt = vim.opt

-- Backward compatibility shim for plugins still using vim.tbl_islist
if vim.tbl_islist then
	vim.tbl_islist = vim.islist
end
-- ============================================================================
-- Core Settings
-- ============================================================================

-- Set leader key first
vim.g.mapleader = " "

-- Editor behavior
opt.expandtab = true -- Use spaces instead of tabs
opt.tabstop = 2 -- Tab width
opt.shiftwidth = 2 -- Indentation width
opt.smartindent = true -- Smart auto-indenting
opt.smarttab = true -- Smart auto-indenting
opt.wrap = false -- Don't wrap lines
opt.swapfile = false -- Disable swap files
opt.undofile = true -- Enable persistent undo
opt.splitright = true -- Vertical split on right
opt.scrolloff = 10 -- Keep 4 lines above/below cursor

-- UI appearance
opt.number = true -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.signcolumn = "yes" -- Always show sign column
opt.cursorcolumn = false -- Don't highlight cursor column
opt.winborder = "rounded" -- Rounded window borders

-- Search and interaction
opt.ignorecase = true -- Case insensitive search
opt.incsearch = true -- Incremental search
opt.mousemoveevent = true -- Enable mouse move events

-- Performance
opt.updatetime = 500
opt.timeoutlen = 400

-- ============================================================================
-- Plugin Management
-- ============================================================================

vim.pack.add({
	-- Theme and UI
	{ src = "https://github.com/catppuccin/nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/brenoprata10/nvim-highlight-colors" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/folke/noice.nvim" },
	{ src = "https://github.com/folke/nui.nvim" },
	{ src = "https://github.com/rcarriga/nvim-notify" },

	-- File management
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },

	-- Editing enhancements
	{ src = "https://github.com/nvim-mini/mini.comment" },
	{ src = "https://github.com/nvim-mini/mini.pairs" },
	{ src = "https://github.com/windwp/nvim-ts-autotag" },

	-- LSP and completion
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/folke/lazydev.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/hrsh7th/nvim-cmp" },
	{ src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
	{ src = "https://github.com/hrsh7th/cmp-buffer" },
	{ src = "https://github.com/hrsh7th/cmp-path" },
	{ src = "https://github.com/hrsh7th/cmp-cmdline" },
	{ src = "https://github.com/saadparwaiz1/cmp_luasnip" },
	{ src = "https://github.com/L3MON4D3/LuaSnip" },
	{ src = "https://github.com/rafamadriz/friendly-snippets" },
	{ src = "https://github.com/onsails/lspkind.nvim" },
	{ src = "https://github.com/ray-x/lsp_signature.nvim" },

	-- Syntax and parsing
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/HiPhish/rainbow-delimiters.nvim" },
	{ src = "https://github.com/mfussenegger/nvim-lint" },

	-- Navigation and workflow
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
	{ src = "https://github.com/mrjones2014/smart-splits.nvim" },

	-- Specialized functionality
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	{ src = "https://github.com/derektata/lorem.nvim" },
	{ src = "https://github.com/3rd/image.nvim" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },
})

-- ============================================================================
-- Key Mappings
-- ============================================================================

local keymap_opts = { noremap = true, silent = true }

-- Utility functions for keymaps
local function desc(description)
	return vim.tbl_extend("force", keymap_opts, { desc = description })
end

-- Basic editor commands
map("n", "+", "<C-a>", desc("Increment number"))
map("n", "-", "<C-x>", desc("Decrement number"))
map("n", "<C-a>", "gg<S-v>G", desc("Select all"))
map("n", "#", "$", desc("Go to end of line"))
map("n", ";", ":", { noremap = true, desc = "Enter command mode" })
map("v", ";", ":", { noremap = true, desc = "Enter command mode" })

-- Search and highlighting
map("n", "<ESC>", ":nohlsearch<CR>", desc("Clear search highlight"))

-- File operations
map("n", "<leader>o", ":update<CR> :source<CR>", desc("Write and source config"))

-- Moving lines
map("n", "<A-j>", ":m .+1<CR>==", desc("Move line down"))
map("n", "<A-k>", ":m .-2<CR>==", desc("Move line up"))
map("v", "<A-j>", ":m '>+1<CR>gv=gv", desc("Move block down"))
map("v", "<A-k>", ":m '<-2<CR>gv=gv", desc("Move block up"))

-- Indentation
map("v", "<", "<gv", desc("Indent left and keep selection"))
map("v", ">", ">gv", desc("Indent right and keep selection"))

-- System clipboard operations
map({ "n", "v", "x" }, "<leader>y", '"+y<CR>', desc("Copy to system clipboard"))
map({ "n", "v", "x" }, "<leader>d", '"+d<CR>', desc("Delete and copy to system clipboard"))
map({ "n", "v", "x" }, "<leader>p", '"+p<CR>', desc("Paste from system clipboard"))

-- File explorer
map("n", "<leader>e", function()
	require("oil").toggle_float()
end, desc("Open Oil file explorer"))

-- Tmux navigation
map("n", "<C-h>", ":TmuxNavigateLeft<CR>", desc("Go to left window"))
map("n", "<C-j>", ":TmuxNavigateDown<CR>", desc("Go to down window"))
map("n", "<C-k>", ":TmuxNavigateUp<CR>", desc("Go to up window"))
map("n", "<C-l>", ":TmuxNavigateRight<CR>", desc("Go to right window"))

-- Buffer management
map("n", "<Tab>", "<CMD>bNext<CR>", desc("Go to next buffer"))
map("n", "<S-Tab>", "<CMD>bprevious<CR>", desc("Go to previous buffer"))
map("n", "<leader>q", "<CMD>bdelete!<CR>", desc("Delete current buffer"))
map("n", "<leader>bo", ":%bd|e#|bd#<CR>", desc("Close other buffers"))
map("n", "<leader><leader>", "<C-^>", desc("Switch to last buffer"))

-- Terminal
map("t", "<Esc>", [[<C-\><C-n>]], desc("Exit terminal mode"))
map("n", "<leader>t", "<CMD>FloatTermToggle<CR>", desc("Open floating terminal"))

-- Window splitting
map("n", "<leader>sh", "<CMD>split<CR> <CMD>Oil<CR>", desc("Split horizontally"))
map("n", "<leader>sv", "<CMD>vsplit<CR> <CMD>Oil<CR>", desc("Split vertically"))

-- ============================================================================
-- LSP Configuration
-- ============================================================================

-- Enable LSP servers
vim.lsp.enable({
	"lua_ls", -- Lua
	"ts_ls", -- TypeScript/JavaScript
	"marksman", -- Markdown
	"clangd", -- C/C++
	"tailwindcss", -- TailwindCSS
	"gopls", -- Go
	"rust_analyzer", -- Rust
	"html", -- HTML
	"cssls", -- CSS
	"hyprls", -- Hyprland config
	"tinymist", -- Typst
})

-- Language server specific configurations
vim.lsp.config["ts_ls"] = {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_dir = function()
		return vim.loop.cwd()
	end,
}

vim.lsp.config["solidity"] = {
	cmd = { "solidity-language-server", "--stdio" },
	filetypes = { "solidity" },
	root_dir = vim.fs.root(0, { "hardhat.config.js", "truffle-config.js", ".git" }),
}

-- ============================================================================
-- Plugin Configurations
-- ============================================================================

require("noice").setup()
-- LSP Signature
require("lsp_signature").setup({
	bind = true,
	handler_opts = { border = "rounded" },
	transparent_background = true,
})

-- Highlight colors
require("nvim-highlight-colors").setup({})

-- Completion setup
local cmp = require("cmp")
local lspkind = require("lspkind")

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif require("luasnip").expand_or_jumpable() then
				require("luasnip").expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif require("luasnip").jumpable(-1) then
				require("luasnip").jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
	}, {
		{ name = "buffer" },
		{ name = "path" },
	}),
	formatting = {
		format = function(entry, vim_item)
			vim_item.kind = lspkind.presets.default[vim_item.kind] .. " " .. vim_item.kind
			vim_item.menu = ({
				nvim_lsp = "[LSP]",
				luasnip = "[Snip]",
				buffer = "[Buf]",
				path = "[Path]",
			})[entry.source.name]
			return vim_item
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
})

-- LuaSnip setup
local ls = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_lua").lazy_load({
	paths = vim.fn.stdpath("config") .. "/snippets",
})
-- LuaSnip keymaps
map("i", "<C-K>", function()
	ls.expand()
end, { silent = true })
map({ "i", "s" }, "<C-L>", function()
	ls.jump(1)
end, { silent = true })
map({ "i", "s" }, "<C-J>", function()
	ls.jump(-1)
end, { silent = true })
map({ "i", "s" }, "<C-E>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end, { silent = true })

require("image").setup()
require("lualine").setup({
	options = {
		icons_enabled = true,
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
		theme = "catppuccin",
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },
		lualine_c = { "filename" },
		lualine_x = { "filetype" },
		lualine_y = { "diff" },
		lualine_z = {},
	},
})
require("floatterm").setup({
	width = 0.9,
	height = 0.7,
	sidebar_width = 0.25,
	border = "double",
})
require("mason").setup()
require("lorem").opts({
	sentence_length = "mixed",
	comma_chance = 0.3,
	max_commas = 2,
	debounce_ms = 200,
})
-- File management
require("oil").setup({
	win_options = { winblend = 20 },
})

-- Editing enhancements
require("mini.pairs").setup()
require("mini.comment").setup({
	mappings = {
		comment_line = "<leader>/",
		comment_visual = "<leader>/",
	},
})

-- Development workflow
require("lazydev").setup()
require("render-markdown").setup({
	completions = { lsp = { enabled = true } },
	latex = { enabled = false },
})
require("nvim-ts-autotag").setup({
	opts = {
		enable_close = true,
		enable_rename = true,
		enable_close_on_slash = false,
	},
})

-- ============================================================================
-- Telescope Configuration
-- ============================================================================
local builtin = require("telescope.builtin")
map("n", "<leader>f", builtin.find_files, desc("Find files"))
map("n", "<leader>bf", builtin.buffers, desc("Find buffers"))
map("n", "<leader>rg", builtin.live_grep, desc("Live grep"))
map("n", "<leader>h", builtin.help_tags, desc("Help tags"))
map("n", "<leader>th", builtin.colorscheme, desc("Choose colorscheme"))
map("n", "<leader>bb", builtin.builtin, desc("Telescope builtins"))
map("n", "<leader>ss", "<CMD>Telescope possession list<CR>", desc("Show sessions"))

-- ============================================================================
-- Smart Splits Configuration
-- ============================================================================
local smart_splits = require("smart-splits")

-- Resizing splits
map("n", "<C-A-h>", smart_splits.resize_left, desc("Resize left"))
map("n", "<C-A-j>", smart_splits.resize_down, desc("Resize down"))
map("n", "<C-A-k>", smart_splits.resize_up, desc("Resize up"))
map("n", "<C-A-l>", smart_splits.resize_right, desc("Resize right"))

-- Moving between splits
map("n", "<C-h>", smart_splits.move_cursor_left, desc("Move to left split"))
map("n", "<C-j>", smart_splits.move_cursor_down, desc("Move to down split"))
map("n", "<C-k>", smart_splits.move_cursor_up, desc("Move to up split"))
map("n", "<C-l>", smart_splits.move_cursor_right, desc("Move to right split"))
map("n", "<C-\\>", smart_splits.move_cursor_previous, desc("Move to previous split"))

-- Swapping buffers between windows
map("n", "<leader><leader>h", smart_splits.swap_buf_left, desc("Swap buffer left"))
map("n", "<leader><leader>j", smart_splits.swap_buf_down, desc("Swap buffer down"))
map("n", "<leader><leader>k", smart_splits.swap_buf_up, desc("Swap buffer up"))
map("n", "<leader><leader>l", smart_splits.swap_buf_right, desc("Swap buffer right"))

-- ============================================================================
-- Linting Configuration
-- ============================================================================

local lint = require("lint")
lint.linters_by_ft = {
	javascript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	python = { "ruff" },
	markdown = { "markdownlint" },
	cpp = { "cpplint" },
	solidity = { "solhint" },
	go = { "golangci-lint" },
	css = { "stylelint" },
	html = { "htmlhint" },
	rust = { "clippy" },
}

-- ============================================================================
-- Code Formatting Configuration
-- ============================================================================

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
		json = { "prettierd" },
		typst = { "typstyle" },
		go = { "gofmt", "goimports-reviser", "golines" },
	},
	format_on_save = {
		lsp_fallback = true,
		async = false,
		timeout_ms = 1000,
	},
})

-- ============================================================================
-- Treesitter Configuration
-- ============================================================================

require("nvim-treesitter.configs").setup({
	ensure_installed = {
		-- Systems programming
		"c",
		"cpp",
		"rust",
		"go",
		-- Web development
		"javascript",
		"typescript",
		"html",
		"css",
		-- Documentation and markup
		"markdown",
		"latex",
		"yaml",
		"typst",
		-- Scripting
		"bash",
		"regex",
		-- Configuration
		"hyprlang",
	},
})

-- ============================================================================
-- Theme and Visual Configuration
-- ============================================================================

-- Catppuccin theme
require("catppuccin").setup({
	flavour = "mocha",
	transparent_background = true,
	integrations = {
		noice = true,
		notify = true,
		cmp = true,
		treesitter = true,
		native_lsp = { enabled = true },
	},
})

vim.cmd("colorscheme catppuccin")

-- Rainbow delimiters colors (Catppuccin)
local rainbow_colors = {
	{ "RainbowDelimiterRed", "#f38ba8" },
	{ "RainbowDelimiterYellow", "#f9e2af" },
	{ "RainbowDelimiterBlue", "#89b4fa" },
	{ "RainbowDelimiterOrange", "#fab387" },
	{ "RainbowDelimiterGreen", "#a6e3a1" },
	{ "RainbowDelimiterViolet", "#cba6f7" },
	{ "RainbowDelimiterCyan", "#94e2d5" },
}

for _, color in ipairs(rainbow_colors) do
	api.nvim_set_hl(0, color[1], { fg = color[2] })
end

-- Telescope transparency
local telescope_groups = {
	"TelescopeNormal",
	"TelescopeBorder",
	"TelescopePromptNormal",
	"TelescopePromptBorder",
	"TelescopeResultsNormal",
	"TelescopeResultsBorder",
	"TelescopePreviewNormal",
	"TelescopePreviewBorder",
}

for _, group in ipairs(telescope_groups) do
	api.nvim_set_hl(0, group, { bg = "none" })
end

-- ============================================================================
-- Autocommands
-- ============================================================================

-- Create augroup for organization
local augroup = api.nvim_create_augroup("UserConfig", { clear = true })

-- Highlight yanked text
vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#94e2d5", fg = "#000000" })
api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight text when yanking",
	group = augroup,
	callback = function()
		vim.highlight.on_yank({
			higroup = "YankHighlight",
			timeout = 100, -- ms
		})
	end,
})

-- Enhanced markdown support
api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	group = augroup,
	callback = function()
		local bufnr = api.nvim_get_current_buf()
		require("vim.treesitter").start(bufnr, "markdown")
	end,
})

-- Automatically reload files changed outside Neovim
api.nvim_create_autocmd("FocusGained", {
	group = augroup,
	command = "checktime",
})

-- Remember cursor position
api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	callback = function()
		local row, col = unpack(api.nvim_buf_get_mark(0, '"'))
		if row > 0 and row <= api.nvim_buf_line_count(0) then
			api.nvim_win_set_cursor(0, { row, col })
		end
	end,
})

-- Terminal configurations
api.nvim_create_autocmd("TermOpen", {
	group = augroup,
	callback = function()
		opt.number = false
		opt.relativenumber = false
		vim.cmd("startinsert")
	end,
})

-- Quick quit for certain file types
api.nvim_create_autocmd("FileType", {
	pattern = {
		"help",
		"qf",
		"lspinfo",
		"checkhealth",
		"fugitive",
		"git",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"netrw",
		"oil",
	},
	group = augroup,
	callback = function(event)
		vim.keymap.set("n", "q", "<cmd>close<cr>", {
			buffer = event.buf,
			silent = true,
		})
	end,
})

-- Floating window utilities
local function create_centered_float(bufnr)
	local width = math.floor(vim.o.columns * 0.6)
	local height = math.floor(vim.o.lines * 0.6)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	}

	api.nvim_open_win(bufnr, true, opts)
end

-- Float help and checkhealth windows
api.nvim_create_autocmd("FileType", {
	pattern = { "help", "checkhealth" },
	group = augroup,
	callback = function(event)
		local bufnr = event.buf
		vim.defer_fn(function()
			if api.nvim_buf_is_valid(bufnr) then
				vim.cmd("close")
				create_centered_float(bufnr)
				vim.keymap.set("n", "q", "<cmd>close<cr>", {
					buffer = bufnr,
					silent = true,
				})
			end
		end, 10)
	end,
})

-- Toggle image.nvim
local images_visible = true
vim.keymap.set("n", "<leader>i", function()
	if images_visible then
		require("image").clear() -- Hide images
	else
		vim.cmd("e %") -- Reload the current buffer
	end
	images_visible = not images_visible
end, { noremap = true, silent = true })
