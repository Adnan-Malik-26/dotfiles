require("lualine").setup({
	options = {
		icons_enabled = true,
		theme = "poimandres",
		component_separators = { left = " ", right = " " },
		section_separators = { left = " ", right = " " },
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { "branch" },
		lualine_c = { "filename" },
		lualine_x = { "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
})
