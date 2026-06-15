-- Blink completion
require("blink.cmp").setup({
	fuzzy = {
		implementation = "lua",
	},
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "fallback" },
		["<C-e>"] = { "cancel", "fallback" },
		["<C-y>"] = { "accept", "fallback" },
		["<C-b>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<C-n>"] = { "select_next", "fallback" },
	},
	appearance = {
		use_nvim_cmp_as_default = false,
		nerd_font_variant = "mono",
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer", "obsidian", "obsidian_tags", "obsidian_new" },
		providers = {
			obsidian = {
				name = "obsidian",
				module = "blink.compat.source",
				opts = { name = "obsidian" },
			},
			obsidian_tags = {
				name = "obsidian_tags",
				module = "blink.compat.source",
				opts = { name = "obsidian_tags" },
			},
			obsidian_new = {
				name = "obsidian_new",
				module = "blink.compat.source",
				opts = { name = "obsidian_new" },
			},
		},
	},
	snippets = {
		preset = "luasnip",
	},
	completion = {
		trigger = {
			show_on_insert_on_trigger_character = true,
		},
		list = {
			selection = {
				preselect = true,
				auto_insert = false,
			},
		},
		menu = {
			border = "rounded",
			draw = {
				treesitter = { "lsp" },
				columns = {
					{ "kind_icon", gap = 1 },
					{ "label", "label_description", gap = 1 },
					{ "kind", "source_name", gap = 1 },
				},
			},
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 100,
			window = { border = "rounded" },
		},
		ghost_text = { enabled = true },
	},
	signature = {
		enabled = true,
		window = { border = "rounded" },
	},
})

-- LuaSnip
local ls = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_lua").lazy_load({
	paths = vim.fn.stdpath("config") .. "/snippets",
})

local map = vim.keymap.set
map("i", "<C-k>", function()
	ls.expand()
end, { silent = true })
map({ "i", "s" }, "<C-l>", function()
	ls.jump(1)
end, { silent = true })
map({ "i", "s" }, "<C-j>", function()
	ls.jump(-1)
end, { silent = true })
map({ "i", "s" }, "<C-q>", function()
	if ls.choice_active() then
		ls.change_choice(1)
	end
end, { silent = true })
