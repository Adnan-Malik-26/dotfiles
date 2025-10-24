-- UI Plugin Configurations
-- Lualine
require("lualine").setup({
	setions = {
		icons_enabled = true,
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
		theme = "catppuccin",
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },
		lualine_c = { "filename" },
		lualine_x = { "filetype" },
		lualine_y = { "diff" },
		lualine_z = {},
	},
})

-- Highlight colors
require("nvim-highlight-colors").setup({})

-- Fidget (LSP progress)
require("fidget").setup({})

-- Oil file explorer
require("oil").setup({
	win_setions = { winblend = 20 },
})
