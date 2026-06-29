-- Treesitter Configuration
---@diagnostic disable-next-line: missing-fields
require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"bash",
		"c",
		"cpp",
		"css",
		"go",
		"html",
		"javascript",
		"lua",
		"markdown",
		"markdown_inline",
		"query",
		"rust",
		"typescript",
		"vim",
		"vimdoc",
		"latex",
		"scss",
		"svelte",
		"tsx",
		"vue",
		"regex",
	},
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
})

require("nvim-treesitter-textobjects").setup({
	select = {
		lookahead = true,
		selection_modes = {
			["@parameter.outer"] = "v",
			["@function.outer"] = "V",
			["@class.outer"] = "<c-v>",
		},
		include_surrounding_whitespace = false,
	},
})

vim.keymap.set({ "x", "o" }, "af", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "if", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ac", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "ic", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
end)
vim.keymap.set({ "x", "o" }, "as", function()
	require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
end)
