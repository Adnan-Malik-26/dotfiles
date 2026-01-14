-- Mono Pastel theme for Neovim with transparent background
-- Save as ~/.config/nvim/colors/mono-pastel.lua
-- Load with :colorscheme mono-pastel

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
	vim.cmd("syntax reset")
end

vim.g.colors_name = "mono-pastel"

-- Color definitions
local colors = {
	bgd = "#111111",
	bg = "#1c1c1c",
	fg = "#e6e6e6",
	black = "#2a2a2a",
	red = "#d8b4b4",
	green = "#c4d6c4",
	yellow = "#ded8b8",
	blue = "#c3cadd",
	magenta = "#dac3dd",
	cyan = "#c3dedd",
	white = "#f2f2f2",
	orange = "#f7dcc6",
	bright_black = "#4a4a4a",
	bright_red = "#e8c8c8",
	bright_green = "#d8e6d8",
	bright_yellow = "#eeeac9",
	bright_blue = "#d5daf1",
	bright_magenta = "#e8d5f1",
	bright_cyan = "#d5f0f0",
	bright_white = "#ffffff",
}

local function hi(group, opts)
	local cmd = "hi " .. group
	if opts.fg then
		cmd = cmd .. " guifg=" .. opts.fg
	end
	if opts.bg then
		cmd = cmd .. " guibg=" .. opts.bg
	end
	if opts.style then
		cmd = cmd .. " gui=" .. opts.style
	end
	if opts.sp then
		cmd = cmd .. " guisp=" .. opts.sp
	end
	vim.cmd(cmd)
end

-- Editor highlights
hi("Normal", { fg = colors.fg, bg = "NONE" })
hi("NormalFloat", { fg = colors.fg, bg = colors.bgd })
hi("FloatBorder", { fg = colors.bright_black, bg = colors.bgd })
hi("SignColumn", { bg = "NONE" })
hi("LineNr", { fg = colors.bright_black, bg = "NONE" })
hi("CursorLineNr", { fg = colors.yellow, bg = "NONE", style = "bold" })
hi("CursorLine", { bg = colors.bgd })
hi("CursorColumn", { bg = colors.bgd })
hi("ColorColumn", { bg = colors.bgd })
hi("Visual", { bg = colors.black })
hi("VisualNOS", { bg = colors.black })
hi("Search", { fg = colors.bgd, bg = colors.yellow })
hi("IncSearch", { fg = colors.bgd, bg = colors.orange })
hi("MatchParen", { fg = colors.bright_magenta, style = "bold" })
hi("Folded", { fg = colors.bright_black, bg = colors.bgd })
hi("FoldColumn", { fg = colors.bright_black, bg = "NONE" })

-- Statusline
hi("StatusLine", { fg = colors.fg, bg = colors.black })
hi("StatusLineNC", { fg = colors.bright_black, bg = colors.bgd })
hi("VertSplit", { fg = colors.bright_black, bg = "NONE" })
hi("WinSeparator", { fg = colors.bright_black, bg = "NONE" })

-- Tab line
hi("TabLine", { fg = colors.bright_black, bg = colors.bgd })
hi("TabLineFill", { bg = "NONE" })
hi("TabLineSel", { fg = colors.fg, bg = colors.black, style = "bold" })

-- Popup menu
hi("Pmenu", { fg = colors.fg, bg = colors.bgd })
hi("PmenuSel", { fg = colors.bgd, bg = colors.blue })
hi("PmenuSbar", { bg = colors.black })
hi("PmenuThumb", { bg = colors.bright_black })

-- Messages
hi("ErrorMsg", { fg = colors.red })
hi("WarningMsg", { fg = colors.yellow })
hi("ModeMsg", { fg = colors.green })
hi("MoreMsg", { fg = colors.cyan })
hi("Question", { fg = colors.cyan })

-- Diff
hi("DiffAdd", { fg = colors.green, bg = "NONE" })
hi("DiffChange", { fg = colors.yellow, bg = "NONE" })
hi("DiffDelete", { fg = colors.red, bg = "NONE" })
hi("DiffText", { fg = colors.blue, bg = colors.bgd })

-- Syntax highlighting
hi("Comment", { fg = colors.bright_black, style = "italic" })
hi("Constant", { fg = colors.orange })
hi("String", { fg = colors.green })
hi("Character", { fg = colors.green })
hi("Number", { fg = colors.orange })
hi("Boolean", { fg = colors.orange })
hi("Float", { fg = colors.orange })
hi("Identifier", { fg = colors.fg })
hi("Function", { fg = colors.blue })
hi("Statement", { fg = colors.magenta })
hi("Conditional", { fg = colors.magenta })
hi("Repeat", { fg = colors.magenta })
hi("Label", { fg = colors.magenta })
hi("Operator", { fg = colors.fg })
hi("Keyword", { fg = colors.magenta })
hi("Exception", { fg = colors.red })
hi("PreProc", { fg = colors.cyan })
hi("Include", { fg = colors.cyan })
hi("Define", { fg = colors.cyan })
hi("Macro", { fg = colors.cyan })
hi("PreCondit", { fg = colors.cyan })
hi("Type", { fg = colors.yellow })
hi("StorageClass", { fg = colors.yellow })
hi("Structure", { fg = colors.yellow })
hi("Typedef", { fg = colors.yellow })
hi("Special", { fg = colors.red })
hi("SpecialChar", { fg = colors.red })
hi("Tag", { fg = colors.blue })
hi("Delimiter", { fg = colors.fg })
hi("SpecialComment", { fg = colors.bright_black, style = "italic" })
hi("Debug", { fg = colors.red })
hi("Underlined", { fg = colors.blue, style = "underline" })
hi("Ignore", { fg = colors.bright_black })
hi("Error", { fg = colors.red, style = "bold" })
hi("Todo", { fg = colors.magenta, bg = "NONE", style = "bold" })

-- Treesitter
hi("@variable", { fg = colors.fg })
hi("@variable.builtin", { fg = colors.red })
hi("@variable.parameter", { fg = colors.fg })
hi("@variable.member", { fg = colors.fg })
hi("@constant", { fg = colors.orange })
hi("@constant.builtin", { fg = colors.orange })
hi("@constant.macro", { fg = colors.cyan })
hi("@string", { fg = colors.green })
hi("@string.escape", { fg = colors.red })
hi("@string.special", { fg = colors.red })
hi("@character", { fg = colors.green })
hi("@number", { fg = colors.orange })
hi("@boolean", { fg = colors.orange })
hi("@float", { fg = colors.orange })
hi("@function", { fg = colors.blue })
hi("@function.builtin", { fg = colors.blue })
hi("@function.macro", { fg = colors.cyan })
hi("@function.method", { fg = colors.blue })
hi("@constructor", { fg = colors.yellow })
hi("@keyword", { fg = colors.magenta })
hi("@keyword.function", { fg = colors.magenta })
hi("@keyword.operator", { fg = colors.magenta })
hi("@keyword.return", { fg = colors.magenta })
hi("@conditional", { fg = colors.magenta })
hi("@repeat", { fg = colors.magenta })
hi("@label", { fg = colors.magenta })
hi("@operator", { fg = colors.fg })
hi("@exception", { fg = colors.red })
hi("@type", { fg = colors.yellow })
hi("@type.builtin", { fg = colors.yellow })
hi("@type.qualifier", { fg = colors.magenta })
hi("@structure", { fg = colors.yellow })
hi("@include", { fg = colors.cyan })
hi("@property", { fg = colors.fg })
hi("@attribute", { fg = colors.cyan })
hi("@comment", { fg = colors.bright_black, style = "italic" })
hi("@punctuation.delimiter", { fg = colors.fg })
hi("@punctuation.bracket", { fg = colors.fg })
hi("@punctuation.special", { fg = colors.red })
hi("@tag", { fg = colors.blue })
hi("@tag.attribute", { fg = colors.cyan })
hi("@tag.delimiter", { fg = colors.fg })

-- LSP
hi("DiagnosticError", { fg = colors.red })
hi("DiagnosticWarn", { fg = colors.yellow })
hi("DiagnosticInfo", { fg = colors.blue })
hi("DiagnosticHint", { fg = colors.cyan })
hi("DiagnosticUnderlineError", { sp = colors.red, style = "underline" })
hi("DiagnosticUnderlineWarn", { sp = colors.yellow, style = "underline" })
hi("DiagnosticUnderlineInfo", { sp = colors.blue, style = "underline" })
hi("DiagnosticUnderlineHint", { sp = colors.cyan, style = "underline" })

-- Git signs
hi("GitSignsAdd", { fg = colors.green })
hi("GitSignsChange", { fg = colors.yellow })
hi("GitSignsDelete", { fg = colors.red })

-- Telescope
hi("TelescopeBorder", { fg = colors.bright_black, bg = "NONE" })
hi("TelescopePromptBorder", { fg = colors.bright_black, bg = "NONE" })
hi("TelescopeResultsBorder", { fg = colors.bright_black, bg = "NONE" })
hi("TelescopePreviewBorder", { fg = colors.bright_black, bg = "NONE" })
hi("TelescopeSelection", { fg = colors.fg, bg = colors.black })
hi("TelescopeSelectionCaret", { fg = colors.magenta, bg = colors.black })
hi("TelescopeMultiSelection", { fg = colors.cyan, bg = colors.black })
hi("TelescopeMatching", { fg = colors.yellow, style = "bold" })
