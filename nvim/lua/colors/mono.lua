-- lua/colors/mono.lua
-- A desaturated, low-contrast colorscheme.
-- To activate: ln -sf ~/.config/nvim/lua/colors/mono.lua ~/.config/nvim/lua/colors/colors.lua

local c = {
	bg = none,
	fg = "#e6e6e6",
	black = "#2a2a2a",
	red = "#d8b4b4",
	green = "#c4d6c4",
	yellow = "#ded8b8",
	blue = "#c3cadd",
	magenta = "#dac3dd",
	cyan = "#c3dedd",
	white = "#f2f2f2",
	br_black = "#4a4a4a",
	br_red = "#e8c8c8",
	br_green = "#d8e6d8",
	br_yellow = "#eeeac9",
	br_blue = "#d5daf1",
	br_magenta = "#e8d5f1",
	br_cyan = "#d5f0f0",
	br_white = "#ffffff",

	-- semantic (derived)
	cur_line = "#222222",
	line_nr = "#383838",
	border = "#333333",
	visual = "#2e2e2e",
	pmenu_bg = "#242424",
	pmenu_sel = "#303030",
	status_bg = "#242424",
	comment = "#505050",
}

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
	vim.cmd("syntax reset")
end
vim.g.colors_name = "mono"
vim.opt.termguicolors = true

local hi = function(name, opts)
	vim.api.nvim_set_hl(0, name, opts)
end

-- ── Editor ───────────────────────────────────────────────────────────────────
hi("Normal", { fg = c.fg, bg = c.bg })
hi("NormalFloat", { fg = c.fg, bg = c.pmenu_bg })
hi("NormalNC", { fg = c.fg, bg = c.bg })
hi("SignColumn", { fg = c.fg, bg = c.bg })
hi("ColorColumn", { bg = c.black })
hi("CursorLine", { bg = c.cur_line })
hi("CursorLineNr", { fg = c.white, bg = c.cur_line, bold = true })
hi("CursorColumn", { bg = c.cur_line })
hi("LineNr", { fg = c.line_nr })
hi("Visual", { bg = c.visual })
hi("VisualNOS", { bg = c.visual })
hi("VertSplit", { fg = c.border, bg = c.bg })
hi("WinSeparator", { fg = c.border, bg = c.bg })
hi("Folded", { fg = c.comment, bg = c.black })
hi("FoldColumn", { fg = c.comment, bg = c.bg })
hi("EndOfBuffer", { fg = c.br_black })
hi("NonText", { fg = c.br_black })
hi("Whitespace", { fg = c.br_black })
hi("SpecialKey", { fg = c.br_black })
hi("MatchParen", { fg = c.br_white, bg = c.br_black, bold = true })
hi("Conceal", { fg = c.comment })
hi("Directory", { fg = c.blue })

-- ── Search ───────────────────────────────────────────────────────────────────
hi("Search", { fg = c.bg, bg = c.yellow })
hi("IncSearch", { fg = c.bg, bg = c.br_yellow, bold = true })
hi("CurSearch", { fg = c.bg, bg = c.br_yellow, bold = true })
hi("Substitute", { fg = c.bg, bg = c.red })

-- ── Statusline ───────────────────────────────────────────────────────────────
hi("StatusLine", { fg = c.fg, bg = c.status_bg })
hi("StatusLineNC", { fg = c.comment, bg = c.status_bg })
hi("WinBar", { fg = c.fg, bg = c.bg })
hi("WinBarNC", { fg = c.comment, bg = c.bg })

-- ── Tabline ──────────────────────────────────────────────────────────────────
hi("TabLine", { fg = c.comment, bg = c.black })
hi("TabLineFill", { bg = c.black })
hi("TabLineSel", { fg = c.fg, bg = c.bg, bold = true })

-- ── Pmenu ────────────────────────────────────────────────────────────────────
hi("Pmenu", { fg = c.fg, bg = c.pmenu_bg })
hi("PmenuSel", { fg = c.white, bg = c.pmenu_sel, bold = true })
hi("PmenuSbar", { bg = c.pmenu_bg })
hi("PmenuThumb", { bg = c.br_black })
hi("PmenuBorder", { fg = c.border, bg = c.pmenu_bg })

-- ── Messages ─────────────────────────────────────────────────────────────────
hi("ErrorMsg", { fg = c.br_red })
hi("WarningMsg", { fg = c.br_yellow })
hi("ModeMsg", { fg = c.fg, bold = true })
hi("MoreMsg", { fg = c.green })
hi("Question", { fg = c.cyan })

-- ── Diagnostics ──────────────────────────────────────────────────────────────
hi("DiagnosticError", { fg = c.red })
hi("DiagnosticWarn", { fg = c.yellow })
hi("DiagnosticInfo", { fg = c.blue })
hi("DiagnosticHint", { fg = c.cyan })
hi("DiagnosticUnnecessary", { fg = c.comment, undercurl = true, sp = c.comment })
hi("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
hi("DiagnosticUnderlineWarn", { undercurl = true, sp = c.yellow })
hi("DiagnosticUnderlineInfo", { undercurl = true, sp = c.blue })
hi("DiagnosticUnderlineHint", { undercurl = true, sp = c.cyan })

-- ── Spelling ─────────────────────────────────────────────────────────────────
hi("SpellBad", { undercurl = true, sp = c.red })
hi("SpellCap", { undercurl = true, sp = c.yellow })
hi("SpellRare", { undercurl = true, sp = c.magenta })
hi("SpellLocal", { undercurl = true, sp = c.cyan })

-- ── Diff ─────────────────────────────────────────────────────────────────────
hi("DiffAdd", { fg = c.green, bg = "#1c261c" })
hi("DiffDelete", { fg = c.red, bg = "#261c1c" })
hi("DiffChange", { bg = "#1c1c26" })
hi("DiffText", { fg = c.br_blue, bg = "#22223a", bold = true })
hi("Added", { fg = c.green })
hi("Removed", { fg = c.red })
hi("Changed", { fg = c.blue })

-- ── Syntax ───────────────────────────────────────────────────────────────────
hi("Comment", { fg = c.comment, italic = true })
hi("Constant", { fg = c.cyan })
hi("String", { fg = c.green })
hi("Character", { fg = c.green })
hi("Number", { fg = c.cyan })
hi("Boolean", { fg = c.cyan })
hi("Float", { fg = c.cyan })
hi("Identifier", { fg = c.fg })
hi("Function", { fg = c.blue })
hi("Statement", { fg = c.magenta })
hi("Conditional", { fg = c.magenta })
hi("Repeat", { fg = c.magenta })
hi("Label", { fg = c.magenta })
hi("Operator", { fg = c.fg })
hi("Keyword", { fg = c.magenta })
hi("Exception", { fg = c.red })
hi("PreProc", { fg = c.yellow })
hi("Include", { fg = c.yellow })
hi("Define", { fg = c.yellow })
hi("Macro", { fg = c.yellow })
hi("PreCondit", { fg = c.yellow })
hi("Type", { fg = c.blue })
hi("StorageClass", { fg = c.blue })
hi("Structure", { fg = c.blue })
hi("Typedef", { fg = c.blue })
hi("Special", { fg = c.cyan })
hi("SpecialChar", { fg = c.cyan })
hi("Tag", { fg = c.blue })
hi("Delimiter", { fg = c.fg })
hi("SpecialComment", { fg = c.comment, bold = true })
hi("Debug", { fg = c.red })
hi("Underlined", { underline = true })
hi("Error", { fg = c.br_red })
hi("Todo", { fg = c.yellow, bold = true })

-- ── Treesitter ───────────────────────────────────────────────────────────────
hi("@comment", { link = "Comment" })
hi("@comment.documentation", { fg = c.comment, italic = true })
hi("@keyword", { link = "Keyword" })
hi("@keyword.function", { fg = c.magenta })
hi("@keyword.operator", { fg = c.fg })
hi("@keyword.return", { fg = c.magenta, italic = true })
hi("@keyword.import", { fg = c.yellow })
hi("@function", { link = "Function" })
hi("@function.builtin", { fg = c.blue, italic = true })
hi("@function.call", { fg = c.blue })
hi("@function.macro", { fg = c.yellow })
hi("@function.method", { fg = c.blue })
hi("@function.method.call", { fg = c.blue })
hi("@constructor", { fg = c.blue })
hi("@variable", { fg = c.fg })
hi("@variable.builtin", { fg = c.cyan, italic = true })
hi("@variable.member", { fg = c.fg })
hi("@variable.parameter", { fg = c.fg })
hi("@property", { fg = c.fg })
hi("@type", { link = "Type" })
hi("@type.builtin", { fg = c.blue, italic = true })
hi("@type.definition", { fg = c.blue })
hi("@string", { link = "String" })
hi("@string.escape", { fg = c.cyan })
hi("@string.special", { fg = c.cyan })
hi("@string.regexp", { fg = c.cyan })
hi("@number", { link = "Number" })
hi("@number.float", { link = "Float" })
hi("@boolean", { link = "Boolean" })
hi("@constant", { link = "Constant" })
hi("@constant.builtin", { fg = c.cyan, italic = true })
hi("@constant.macro", { fg = c.yellow })
hi("@module", { fg = c.fg })
hi("@namespace", { fg = c.fg })
hi("@operator", { link = "Operator" })
hi("@punctuation.delimiter", { fg = c.fg })
hi("@punctuation.bracket", { fg = c.br_black })
hi("@punctuation.special", { fg = c.cyan })
hi("@tag", { fg = c.blue })
hi("@tag.attribute", { fg = c.fg })
hi("@tag.delimiter", { fg = c.comment })
hi("@markup.heading", { fg = c.fg, bold = true })
hi("@markup.italic", { italic = true })
hi("@markup.strong", { bold = true })
hi("@markup.underline", { underline = true })
hi("@markup.strikethrough", { strikethrough = true })
hi("@markup.link.uri", { fg = c.cyan, underline = true })
hi("@markup.link", { fg = c.blue })
hi("@markup.raw", { fg = c.green })
hi("@attribute", { fg = c.yellow })
hi("@label", { fg = c.magenta })
hi("@exception", { fg = c.red })

-- ── LSP semantic tokens ──────────────────────────────────────────────────────
hi("LspReferenceText", { bg = c.visual })
hi("LspReferenceRead", { bg = c.visual })
hi("LspReferenceWrite", { bg = c.visual, bold = true })
hi("LspInlayHint", { fg = c.comment, italic = true })
hi("@lsp.type.class", { fg = c.blue })
hi("@lsp.type.enum", { fg = c.blue })
hi("@lsp.type.interface", { fg = c.blue, italic = true })
hi("@lsp.type.struct", { fg = c.blue })
hi("@lsp.type.typeParameter", { fg = c.blue })
hi("@lsp.type.parameter", { fg = c.fg })
hi("@lsp.type.variable", { fg = c.fg })
hi("@lsp.type.property", { fg = c.fg })
hi("@lsp.type.enumMember", { fg = c.cyan })
hi("@lsp.type.function", { fg = c.blue })
hi("@lsp.type.method", { fg = c.blue })
hi("@lsp.type.macro", { fg = c.yellow })
hi("@lsp.type.decorator", { fg = c.yellow })
hi("@lsp.type.namespace", { fg = c.fg })
hi("@lsp.type.keyword", { fg = c.magenta })
hi("@lsp.type.comment", { link = "Comment" })
hi("@lsp.type.string", { link = "String" })
hi("@lsp.type.number", { link = "Number" })
hi("@lsp.type.operator", { link = "Operator" })
hi("@lsp.mod.deprecated", { strikethrough = true })
hi("@lsp.mod.readonly", { italic = true })
hi("@lsp.mod.static", { italic = true })

-- ── Gitsigns ─────────────────────────────────────────────────────────────────
hi("GitSignsAdd", { fg = c.green })
hi("GitSignsChange", { fg = c.blue })
hi("GitSignsDelete", { fg = c.red })

-- ── Telescope ────────────────────────────────────────────────────────────────
hi("TelescopeNormal", { fg = c.fg, bg = c.pmenu_bg })
hi("TelescopeBorder", { fg = c.border, bg = c.pmenu_bg })
hi("TelescopePromptBorder", { fg = c.border, bg = c.pmenu_bg })
hi("TelescopeResultsBorder", { fg = c.border, bg = c.pmenu_bg })
hi("TelescopePreviewBorder", { fg = c.border, bg = c.pmenu_bg })
hi("TelescopeSelection", { fg = c.white, bg = c.pmenu_sel, bold = true })
hi("TelescopeSelectionCaret", { fg = c.magenta, bg = c.pmenu_sel })
hi("TelescopeMatching", { fg = c.yellow, bold = true })
hi("TelescopePromptPrefix", { fg = c.magenta })

-- ── nvim-cmp ─────────────────────────────────────────────────────────────────
hi("CmpItemAbbr", { fg = c.fg })
hi("CmpItemAbbrMatch", { fg = c.yellow, bold = true })
hi("CmpItemAbbrMatchFuzzy", { fg = c.yellow })
hi("CmpItemAbbrDeprecated", { fg = c.comment, strikethrough = true })
hi("CmpItemKind", { fg = c.blue })
hi("CmpItemMenu", { fg = c.comment })
hi("CmpItemKindFunction", { fg = c.blue })
hi("CmpItemKindMethod", { fg = c.blue })
hi("CmpItemKindVariable", { fg = c.fg })
hi("CmpItemKindField", { fg = c.fg })
hi("CmpItemKindKeyword", { fg = c.magenta })
hi("CmpItemKindSnippet", { fg = c.yellow })
hi("CmpItemKindText", { fg = c.fg })

-- ── Bufferline ───────────────────────────────────────────────────────────────
hi("BufferLineFill", { bg = c.black })
hi("BufferLineBackground", { fg = c.comment, bg = c.black })
hi("BufferLineBufferSelected", { fg = c.white, bg = c.bg, bold = true })
hi("BufferLineBufferVisible", { fg = c.fg, bg = c.black })
hi("BufferLineSeparator", { fg = c.border, bg = c.black })
hi("BufferLineModified", { fg = c.yellow, bg = c.black })
hi("BufferLineModifiedSelected", { fg = c.yellow, bg = c.bg })

-- ── Snacks.nvim ──────────────────────────────────────────────────────────────
hi("SnacksNormal", { link = "NormalFloat" })
hi("SnacksBorder", { fg = c.border, bg = c.pmenu_bg })
hi("SnacksPickerMatch", { fg = c.yellow, bold = true })
