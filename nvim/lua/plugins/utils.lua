-- Utility Plugin Configurations
-- Mini plugins
require("mini.pairs").setup()
require("mini.comment").setup({
	mappings = {
		comment_line = "<leader>/",
		comment_visual = "<leader>/",
	},
})

-- Render markdown
require("render-markdown").setup({
	completions = { lsp = { enabled = true } },
	latex = { enabled = false },
})

-- Auto tag for HTML/JSX
require("nvim-ts-autotag").setup({
	sets = {
		enable_close = true,
		enable_rename = true,
		enable_close_on_slash = false,
	},
})

-- Lorem ipsum generator
---@diagnostic disable-next-line: missing-fields
require("lorem").opts({
	sentence_length = "mixed",
	comma_chance = 0.3,
	max_commas = 2,
	debounce_ms = 200,
})

-- Peek markdown preview
require("peek").setup()
vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})

-- Checkmate (TODO management)
require("checkmate").setup()

-- Obsidian integration
require("obsidian").setup({
	workspaces = {
		{
			name = "Programming",
			path = "~/Notes/Programming",
		},
		{
			name = "Networking",
			path = "~/Notes/Networking/",
		},
	},
	completion = {
		nvim_cmp = true,
		min_chars = 2,
	},
	mappings = {
		["gf"] = {
			action = function()
				return require("obsidian").util.gf_passthrough()
			end,
			opts = { noremap = false, expr = true, buffer = true },
		},
		["<leader>ch"] = {
			action = function()
				return require("obsidian").util.toggle_checkbox()
			end,
			opts = { buffer = true },
		},
		["<cr>"] = {
			action = function()
				return require("obsidian").util.smart_action()
			end,
			opts = { buffer = true, expr = true },
		},
	},
	ui = {
		enable = false,
	},
})
