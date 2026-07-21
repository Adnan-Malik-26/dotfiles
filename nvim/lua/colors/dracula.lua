vim.cmd('packadd dracula.nvim')

require("dracula").setup({
	transparent_bg = true,
})

vim.cmd("colorscheme dracula")
