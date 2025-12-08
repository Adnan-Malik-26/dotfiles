-- Theme and Visual Configuration
---@diagnostic disable-next-line: missing-fields
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

require("everforest").setup({
	background = "soft",
	transparent_background_level = 1,
})

-- Nord Theme
vim.g.nord_contrast = true
vim.g.nord_disable_background = true

require("dracula").setup({
	transparent_bg = true,
})

require("gruvbox").setup({
	transparent_mode = true,
})

require("rose-pine").setup({
	dark_variant = "main",
	styles = {
		transparency = true,
	},
})
-- Rainbow delimiter colors
local rainbow_colors = {
	{ "RainbowDelimiterRed", "#f38ba8" },
	{ "RainbowDelimiterYellow", "#f9e2af" },
	{ "RainbowDelimiterBlue", "#89b4fa" },
	{ "RainbowDelimiterOrange", "#fab387" },
	{ "RainbowDelimiterGreen", "#a6e3a1" },
	{ "RainbowDelimiterViolet", "#cba6f7" },
	{ "RainbowDelimiterCyan", "#94e2d5" },
}

for _, color in ipairs(rainbow_colors) do
	vim.api.nvim_set_hl(0, color[1], { fg = color[2] })
end

-- Telescope transparent background
local telescope_groups = {
	"TelescopeNormal",
	"TelescopeBorder",
	"TelescopePromptNormal",
	"TelescopePromptBorder",
	"TelescopeResultsNormal",
	"TelescopeResultsBorder",
	"TelescopePreviewNormal",
	"TelescopePreviewBorder",
}

for _, group in ipairs(telescope_groups) do
	vim.api.nvim_set_hl(0, group, { bg = "none" })
end
