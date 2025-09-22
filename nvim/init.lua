-- ============================================================================
-- Neovim Configuration
-- ============================================================================

local vim = vim
local map = vim.keymap.set
local o = vim.opt
local mapopts = { noremap = true, silent = true }
-- ============================================================================
-- Core Settings
-- ============================================================================

-- Editor behavior
o.expandtab = true -- Use spaces instead of tabs
o.tabstop = 2 -- Tab width
o.shiftwidth = 2 -- Indentation width
o.smartindent = true -- Smart auto-indenting
o.smarttab = true -- Smart auto-indenting
o.wrap = false -- Don't wrap lines

o.swapfile = false -- Disable swap files
o.undofile = true -- Enable persistent undo
o.splitright = true -- Vertical Split on right
o.scrolloff = 4

-- UI appearance
o.number = true -- Show line numbers
o.relativenumber = true -- Show relative line numbers
o.signcolumn = "yes" -- Always show sign column
o.cursorcolumn = false -- Don't highlight cursor column
o.cmdheight = 0 -- Hide command line (shows in popup)
o.winborder = "rounded" -- Rounded window borders

-- Search and interaction
o.ignorecase = true -- Case insensitive search
o.incsearch = true -- Incremental search
o.mousemoveevent = true -- Enable mouse move events

-- Performance
o.updatetime = 200
o.timeoutlen = 400

-- ============================================================================
-- Key Mappings
-- ============================================================================

-- Set leader key
vim.g.mapleader = " "

-- Increment and Decrement
map("n", "+", "<C-a>", { desc = "Increment Number under Cursor" }, mapopts)
map("n", "-", "<C-x>", { desc = "Decrement Number under Cursor" }, mapopts)

-- Select Everything
map("n", "<C-a>", "gg<S-v>G", { desc = "Select all" }, mapopts)

-- Highlight
map("n", "<leader>nh", ":nohlsearch<CR>", { desc = "Clear search highlight" }, mapopts)
map("n", "<ESC>", ":nohlsearch<CR>", { desc = "Clear search highlight" }, mapopts)

-- File operations
map("n", "<leader>o", ":update<CR> :source<CR>", { desc = "Write and source config" }, mapopts)

-- Moving Lines
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" }, mapopts)
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" }, mapopts)
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move block down" }, mapopts)
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move block up" }, mapopts)

-- Keep selection after indenting
map("v", "<", "<gv", { desc = "Indent left and keep selection" }, mapopts)
map("v", ">", ">gv", { desc = "Indent right and keep selection" }, mapopts)

-- System clipboard operations
map({ "n", "v", "x" }, "<leader>y", '"+y<CR>', { desc = "Copy to system clipboard" }, mapopts)
map({ "n", "v", "x" }, "<leader>d", '"+d<CR>', { desc = "Delete and copy to system clipboard" }, mapopts)
map({ "n", "v", "x" }, "<leader>p", '"+p<CR>', { desc = "Paste from system clipboard" }, mapopts)

-- Navigation shortcuts
map("n", "#", "$", { noremap = true, silent = true, desc = "Go to end of line" }, mapopts)
map("n", ";", ":", { noremap = true, desc = "Enter command mode" }, mapopts)
map("v", ";", ":", { noremap = true, desc = "Enter command mode" }, mapopts)

-- File explorer
map("n", "<leader>e", function()
	require("oil").toggle_float()
end, { desc = "Open Oil File Explorer" }, mapopts)

-- LSP formatting
map("n", "<leader>lf", vim.lsp.buf.format, { desc = "Format with LSP" }, mapopts)

-- Tmux navigation
map("n", "<C-h>", ":TmuxNavigateLeft<CR>", { desc = "Go to left window" }, mapopts)
map("n", "<C-j>", ":TmuxNavigateDown<CR>", { desc = "Go to down window" }, mapopts)
map("n", "<C-k>", ":TmuxNavigateUp<CR>", { desc = "Go to up window" }, mapopts)
map("n", "<C-l>", ":TmuxNavigateRight<CR>", { desc = "Go to right window" }, mapopts)

-- Buffer
map("n", "<Tab>", "<CMD>bNext<CR>", { desc = "Go to next buffer" }, mapopts)
map("n", "<S-Tab>", "<CMD>bprevious<CR>", { desc = "Go to previous buffer" }, mapopts)
map("n", "<leader>q", "<CMD>bdelete!<CR>", { desc = "Delete current buffer" }, mapopts)
map("n", "<leader>bo", ":%bd|e#|bd#<CR>", { desc = "Close other buffers" }, mapopts)
map("n", "<leader><leader>", "<C-^>", { desc = "Switch to last buffer" }, mapopts)

-- Tab
map("n", "te", "<CMD>tabnew<CR>", { desc = "Open a new tab" }, mapopts)
map("n", "tn", "<CMD>tabnext<CR>", { desc = "Next Tab" }, mapopts)

-- Terminal
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" }, mapopts)
map("n", "<leader>t", "<CMD>FloatTermToggle<CR>", { desc = "Open Floating Terminal" }, mapopts)

-- Splitting Windows
map("n", "<leader>sh", "<CMD>split<CR> <CMD>Oil<CR>", { desc = "Split Buffer Horizontally" }, mapopts)
map("n", "<leader>sv", "<CMD>vsplit<CR> <CMD>Oil<CR>", { desc = "Split Buffer Vertically" }, mapopts)

-- ============================================================================
-- Plugin Management
-- ============================================================================

vim.pack.add({
	-- Theme and UI
	{ src = "https://github.com/catppuccin/nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/RRethy/base16-nvim" },
	{ src = "https://github.com/linux-cultist/venv-selector.nvim" },

	-- File management
	{ src = "https://github.com/stevearc/Oil.nvim" },
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
	{ src = "https://github.com/Saghen/blink.cmp" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/chomosuke/typst-preview.nvim" },

	-- Syntax and parsing
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/HiPhish/rainbow-delimiters.nvim" },

	-- Navigation and workflow
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },
	{ src = "https://github.com/folke/todo-comments.nvim" },
	{ src = "https://github.com/mrjones2014/smart-splits.nvim" },

	-- Specialized functionality
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	{ src = "https://github.com/derektata/lorem.nvim" },
	{ src = "https://github.com/3rd/image.nvim" },
	{ src = "https://github.com/3rd/diagram.nvim" },
	{ src = "https://github.com/jedrzejboczar/possession.nvim" },
})

-- ============================================================================
-- LSP Configuration
-- ============================================================================

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

-- ============================================================================
-- Plugin Setup and Configuration
-- ============================================================================
require("books").setup({
	-- Keybindings
	keymap_add = "<leader>ba", -- Add bookmark
	keymap_list = "<leader>bl", -- Show all bookmarks
	keymap_project = "<leader>bp", -- Show project bookmarks
	keymap_session = "<leader>bs", -- Show session bookmarks
	keymap_global = "<leader>bg", -- Show global bookmarks
	keymap_delete = "<leader>bd", -- Delete bookmark at cursor

	-- Organization
	project_based = true, -- Enable project grouping
	session_based = true, -- Enable session grouping
	auto_save = true, -- Auto-save on changes
	auto_cleanup = true, -- Remove invalid bookmarks

	-- Display
	show_line_numbers = true, -- Show [line] in display
	show_relative_paths = true, -- Show relative paths
	max_description_length = 50, -- Truncate long descriptions

	-- Categories
	default_categories = {
		"TODO",
		"FIXME",
		"NOTE",
		"IMPORTANT",
		"REFERENCE",
	},

	-- Preview
	preview = {
		enabled = true,
		context_lines = 5, -- Lines before/after bookmark
		syntax_highlight = true,
	},
})

require("urlplus").setup({
	keymap = "<leader>u", -- Open telescope with URLs
	keymap_copy = "<leader>uc", -- Copy all URLs
	keymap_open = "<leader>uo", -- Open all URLs in browser

	show_preview = true, -- Show context preview
	sort_by = "line", -- "line", "url", "type"

	-- URL type icons
	icons = {
		https = "🔒",
		http = "🌐",
		ftp = "📁",
		git = "🔗",
		www = "🌍",
	},

	ignore_patterns = {
		"127%.0%.0%.1",
		"localhost",
		"%d+%.%d+%.%d+",
	},
})

require("refiles").setup({
	max_recent_files = 100,
	keymap = "<leader>r", -- Smart recent files
	keymap_project = "<leader>rp", -- Project files only
	-- keymap_global = "<leader>rg", -- All files
	project_based = true, -- Enable project filtering
	show_modified_indicator = true, -- Show ● for modified buffers
	show_git_status = true, -- Show git status
	auto_cleanup = true, -- Remove deleted files
	ignore_patterns = { -- Files to ignore
		"%.git/",
		"node_modules/",
		"%.pyc$",
		"/tmp/",
	},
	file_icons = { -- Customize icons
		lua = "🌙",
		py = "🐍",
		js = "📜",
	},
})

require("yankhist").setup({
	max_history = 50,
	keymap = "<leader>c",
	ignore_empty = true,
	ignore_single_char = true,
})

-- Venv Selector setup
require("venv-selector").setup({
	ft = "python", -- optional, load only for Python files
	keys = {
		{ ",v", "<cmd>VenvSelect<cr>" }, -- open picker with ,v
	},
	options = {
		-- optional global options
		enable_default_searches = true,
		notify_user_on_venv_activation = true,
		picker = "auto", -- telescope / fzf-lua / native
	},
	search = {
		-- Example: find venvs under ~/Code
		my_venvs = {
			command = "fd python$ ~/Code --full-path -a -L",
		},
	},
})
-- Core functionality
require("image").setup()
require("possession").setup({})
require("telescope").load_extension("possession")
require("edline").setup()
require("floatterm").setup({
	width = 0.9, -- 90% screen width
	height = 0.7, -- 70% screen height
	sidebar_width = 0.25, -- 25% of window width
	border = "double", -- different border style
})

require("mason").setup()

-- Text generation
require("lorem").opts({
	sentence_length = "mixed",
	comma_chance = 0.3,
	max_commas = 2,
	debounce_ms = 200,
})

-- Telescope (fuzzy finder) keymaps
local builtin = require("telescope.builtin")
map("n", "<leader>f", builtin.find_files, { desc = "Find files" })
map("n", "<leader>bf", builtin.buffers, { desc = "Find buffers" })
map("n", "<leader>rg", builtin.live_grep, { desc = "Live grep" })
map("n", "<leader>h", builtin.help_tags, { desc = "Help tags" })
map("n", "<leader>th", builtin.colorscheme, { desc = "Choose colorscheme" })
map("n", "<leader>bb", builtin.builtin, { desc = "Telescope builtins" })
map("n", "<leader>ss", "<CMD>Telescope possession list<CR>", { desc = "Show Sessions" })
map("n", "<leader>v", "<cmd>VenvSelect<CR>", { desc = "Select Python venv" })

-- Development tools
require("lazydev").setup()
require("oil").setup({
	win_options = {
		winblend = 20,
	},
})

-- Editing enhancements
require("mini.pairs").setup()
require("mini.comment").setup({
	mappings = {
		comment_line = "<leader>/",
		comment_visual = "<leader>/",
	},
})

-- Completion setup
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

-- Rainbow Delimiters Catppuccin
vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = "#f38ba8" })
vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = "#f9e2af" })
vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = "#89b4fa" })
vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = "#fab387" })
vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = "#a6e3a1" })
vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = "#cba6f7" })
vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = "#94e2d5" })

-- ============================================================================
-- Language Server Specific Configuration
-- ============================================================================

-- TypeScript/JavaScript
require("lspconfig").ts_ls.setup({
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_dir = function()
		return vim.loop.cwd()
	end,
})

-- Solidity
require("lspconfig").solidity.setup({
	cmd = { "solidity-language-server", "--stdio" },
	filetypes = { "solidity" },
	root_dir = require("lspconfig.util").root_pattern("hardhat.config.js", "truffle-config.js", ".git"),
})

-- ============================================================================
-- Code Formatting
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
		"markdown_inline",
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
-- Specialized Plugin Configuration
-- ============================================================================

-- keymaps for splitting
map("n", "<C-A-h>", require("smart-splits").resize_left)
map("n", "<C-A-j>", require("smart-splits").resize_down)
map("n", "<C-A-k>", require("smart-splits").resize_up)
map("n", "<C-A-l>", require("smart-splits").resize_right)
-- moving between splits
map("n", "<C-h>", require("smart-splits").move_cursor_left)
map("n", "<C-j>", require("smart-splits").move_cursor_down)
map("n", "<C-k>", require("smart-splits").move_cursor_up)
map("n", "<C-l>", require("smart-splits").move_cursor_right)
map("n", "<C-\\>", require("smart-splits").move_cursor_previous)
-- swapping buffers between windows
map("n", "<leader><leader>h", require("smart-splits").swap_buf_left)
map("n", "<leader><leader>j", require("smart-splits").swap_buf_down)
map("n", "<leader><leader>k", require("smart-splits").swap_buf_up)
map("n", "<leader><leader>l", require("smart-splits").swap_buf_right)

-- Markdown rendering
require("render-markdown").setup({
	completions = { lsp = { enabled = true } },
	latex = { enabled = false },
})

-- Code comments highlighting
require("todo-comments").setup()

-- Auto-close HTML/JSX tags
require("nvim-ts-autotag").setup({
	opts = {
		enable_close = true,
		enable_rename = true,
		enable_close_on_slash = false,
	},
})

-- ============================================================================
-- Theme and Visual Configuration
-- ============================================================================

-- Catppuccin theme setup
require("catppuccin").setup({
	flavour = "mocha",
	transparent_background = true,
	custom_highlights = {
		WinSeparator = { fg = "#9399b2" },
		BlinkCmpDocBorder = { fg = "#89b4fa" },
		BlinkCmpKind = { fg = "#89b4fa" },
		BlinkCmpMenu = { fg = "#cdd6f4" },
		BlinkCmpMenuBorder = { fg = "#89b4fa" },
		BlinkCmpSignatureHelpActiveParameter = { fg = "#cba6f7" },
		BlinkCmpSignatureHelpBorder = { fg = "#89b4fa" },
	},
	floating_border = "on",
})

-- Apply colorscheme
vim.cmd("colorscheme catppuccin")

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
	vim.api.nvim_set_hl(0, group, { bg = "none" })
end

-- ============================================================================
-- Autocommands
-- ============================================================================

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight text when yanking",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Enhanced markdown support
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		require("vim.treesitter").start(bufnr, "markdown")
	end,
})

-- Automatically reload a file if it's changed outside of Neovim
vim.api.nvim_create_autocmd("FocusGained", { command = "checktime" })

-- Remember cursor position when reopening a file
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local row, col = unpack(vim.api.nvim_buf_get_mark(0, '"'))
		if row > 0 and row <= vim.api.nvim_buf_line_count(0) then
			vim.api.nvim_win_set_cursor(0, { row, col })
		end
	end,
})

-- Auto-format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",
	callback = function(args)
		require("conform").format({ bufnr = args.buf })
	end,
})

-- Don't show line numbers in terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
	command = "setlocal nonumber norelativenumber",
})

-- Open `:terminal` in insert mode
vim.api.nvim_create_autocmd("TermOpen", {
	command = "startinsert",
})

-- 'q' quits on certain files
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"help",
		"qf", -- quickfix
		"lspinfo",
		"checkhealth",
		"fugitive",
		"git", -- fugitive/git windows
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"netrw", -- file explorer
	},
	callback = function(event)
		vim.keymap.set("n", "q", "<cmd>close<cr>", {
			buffer = event.buf,
			silent = true,
		})
	end,
})

-- Function to create a centered floating window
local function open_centered_float(bufnr)
	local width = math.floor(vim.o.columns * 0.6) -- 60% of screen width
	local height = math.floor(vim.o.lines * 0.6) -- 60% of screen height
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

	vim.api.nvim_open_win(bufnr, true, opts)
end

-- Autocmd for help and checkhealth
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "help", "checkhealth" },
	callback = function(event)
		local bufnr = event.buf

		-- Close the default split before reopening in float
		vim.defer_fn(function()
			if vim.api.nvim_buf_is_valid(bufnr) then
				vim.cmd("close") -- close the default window
				open_centered_float(bufnr)
				vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = bufnr, silent = true })
			end
		end, 10)
	end,
})
