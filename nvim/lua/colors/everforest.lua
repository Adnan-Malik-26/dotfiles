vim.cmd('packadd everforest-nvim')

require("everforest").setup({
	background = "soft",
	transparent_background_level = 1,
})

vim.cmd("colorscheme everforest")
