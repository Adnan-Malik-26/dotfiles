-- Theme and Visual Configuration
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
