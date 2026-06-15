-- Completion Configuration
local cmp = require("cmp")
local lspkind = require("lspkind")

-- CMP setup
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
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
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

-- LuaSnip configuration
local ls = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_lua").lazy_load({
	paths = vim.fn.stdpath("config") .. "/snippets",
})

-- LuaSnip keymaps
local map = vim.keymap.set

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
