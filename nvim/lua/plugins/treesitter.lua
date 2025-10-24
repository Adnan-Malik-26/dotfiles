-- Treesitter Configuration
---@diagnostic disable-next-line: missing-fields
require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"c",
		"cpp",
		"go",
		"javascript",
		"typescript",
		"svelte",
		"html",
		"css",
		"markdown",
		"typst",
		"bash",
	},
	highlight = {
		enable = true,
	},
	indent = {
		enable = true,
	},
})
