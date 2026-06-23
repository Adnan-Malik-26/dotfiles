require("tree-sitter-manager").setup({
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
	auto_install = true,
	highlight = true,
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		pcall(vim.treesitter.start)
	end,
})
