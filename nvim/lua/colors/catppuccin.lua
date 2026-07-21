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
