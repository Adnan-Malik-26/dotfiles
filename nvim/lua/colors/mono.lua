-- require("poimandres").setup({
-- 	bold_vert_split = false, -- use bold vertical separators
-- 	dim_nc_background = false, -- dim 'non-current' window backgrounds
-- 	disable_background = true, -- disable background
-- 	disable_float_background = true, -- disable background for floats
-- 	disable_italics = false, -- disable italics
-- })
--

local M = {}

local colors = {
	-- base
	bgd = "#111111",
	bg = "#1c1c1c",
	fg = "#e6e6e6",
	white = "#f2f2f2",
	bwhite = "#ffffff",

	-- grays (derived from black/bright_black)
	black = "#2a2a2a",
	bblack = "#4a4a4a",
	mid = "#3a3a3a", -- interpolated midpoint

	-- pastel accents
	red = "#d8b4b4",
	lred = "#e8c8c8",
	green = "#c4d6c4",
	lgreen = "#d8e6d8",
	yellow = "#ded8b8",
	lyellow = "#eeeac9",
	blue = "#c3cadd",
	lblue = "#d5daf1",
	magenta = "#dac3dd",
	lmagenta = "#e8d5f1",
	cyan = "#c3dedd",
	lcyan = "#d5f0f0",
	orange = "#f7dcc6",
}

function M.colorscheme()
	vim.cmd("highlight clear")
	vim.cmd("syntax reset")

	vim.o.background = "dark"
	vim.g.colors_name = "caelus"

	local set = vim.api.nvim_set_hl

	-- ui (transparent bg = no bg field on Normal)
	set(0, "Normal", { fg = colors.fg })
	set(0, "NormalFloat", { fg = colors.fg, bg = colors.bgd })
	set(0, "FloatBorder", { fg = colors.bblack, bg = colors.bgd })
	set(0, "CursorLine", { bg = colors.black })
	set(0, "Visual", { bg = colors.mid })
	set(0, "Search", { fg = colors.bgd, bg = colors.yellow })
	set(0, "IncSearch", { fg = colors.bgd, bg = colors.orange })
	set(0, "StatusLine", { bg = colors.black })
	set(0, "StatusLineNC", { bg = colors.bgd })
	set(0, "VertSplit", { fg = colors.bblack })
	set(0, "WinSeparator", { fg = colors.bblack })
	set(0, "LineNr", { fg = colors.bblack })
	set(0, "CursorLineNr", { fg = colors.orange, bold = true })
	set(0, "SignColumn", {}) -- transparent
	set(0, "Folded", { fg = colors.bblack, bg = colors.black })

	-- popup
	set(0, "Pmenu", { fg = colors.fg, bg = colors.black })
	set(0, "PmenuSel", { fg = colors.bgd, bg = colors.blue })
	set(0, "PmenuSbar", { bg = colors.black })
	set(0, "PmenuThumb", { bg = colors.bblack })

	-- syntax
	set(0, "Comment", { fg = colors.bblack, italic = true })
	set(0, "Constant", { fg = colors.magenta })
	set(0, "String", { fg = colors.green })
	set(0, "Identifier", { fg = colors.blue })
	set(0, "Function", { fg = colors.yellow })
	set(0, "Statement", { fg = colors.red })
	set(0, "Type", { fg = colors.cyan, bold = true })
	set(0, "Special", { fg = colors.orange })
	set(0, "Error", { fg = colors.lred, bold = true })
	set(0, "Keyword", { fg = colors.red })
	set(0, "Variable", { fg = colors.fg })
	set(0, "TSKeyword", { fg = colors.red })
	set(0, "TSFunction", { fg = colors.yellow })
	set(0, "TSVariable", { fg = colors.fg })
	set(0, "TSType", { fg = colors.cyan })

	-- blink
	set(0, "BlinkCmpMenu", { bg = colors.bgd })
	set(0, "BlinkCmpMenuBorder", { fg = colors.bblack, bg = colors.bgd })
	set(0, "BlinkCmpMenuSelection", { fg = colors.bgd, bg = colors.blue })
	set(0, "BlinkCmpLabel", { fg = colors.fg })
	set(0, "BlinkCmpLabelDetail", { fg = colors.bblack })
	set(0, "BlinkCmpLabelDescription", { fg = colors.bblack })
	set(0, "BlinkCmpLabelMatch", { fg = colors.orange, bold = true })
	set(0, "BlinkCmpKind", { fg = colors.cyan })
	set(0, "BlinkCmpDoc", { fg = colors.fg, bg = colors.black })
	set(0, "BlinkCmpDocBorder", { fg = colors.bblack, bg = colors.black })

	if package.loaded["lualine"] then
		require("lualine").setup({
			options = { theme = "auto" },
		})
	end
end

return M

-- vim.cmd("colorscheme koda-dark")

-- Monochrome.nvim Transparent background
-- local transparent_groups = {
-- 	"Normal",
-- 	"NormalNC",
-- 	"NormalFloat",
-- 	"FloatBorder",
-- 	"FloatTitle",
-- 	"SignColumn",
-- 	"EndOfBuffer",
-- 	"LineNr",
-- 	"FoldColumn",
-- 	"CursorLineNr",
-- 	"StatusLine",
-- 	"StatusLineNC",
-- 	"TabLineFill",
-- 	"WinSeparator",
-- }
--
-- for _, group in ipairs(transparent_groups) do
-- 	vim.api.nvim_set_hl(0, group, { bg = "NONE" })
-- end
