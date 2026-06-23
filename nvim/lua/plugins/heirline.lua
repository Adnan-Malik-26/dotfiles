local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

local colors = {
	bg = "#1a1b26",
	fg = "#e6e6e6",

	blue = "#c3cadd",
	green = "#c4d6c4",
	yellow = "#ded8b8",
	red = "#d8b4b4",
	magenta = "#dac3dd",
	cyan = "#c3dedd",
	orange = "#f7dcc6",
	gray = "#4a4a4a",
}

--------------------------------------------------------------------------------
-- MODE
--------------------------------------------------------------------------------

local mode_names = {
	n = "NORMAL",
	no = "NORMAL",
	v = "VISUAL",
	V = "V-LINE",
	["\22"] = "V-BLOCK",
	s = "SELECT",
	S = "S-LINE",
	i = "INSERT",
	R = "REPLACE",
	c = "COMMAND",
	r = "PROMPT",
	t = "TERMINAL",
}

local mode_colors = {
	n = colors.blue,
	i = colors.green,
	v = colors.magenta,
	V = colors.magenta,
	["\22"] = colors.magenta,
	c = colors.yellow,
	R = colors.red,
	t = colors.red,
}

local Mode = {
	init = function(self)
		self.mode = vim.fn.mode(1)
	end,

	provider = function(self)
		local icon = "󰆍 "
		local name = mode_names[self.mode] or self.mode
		return string.format(" %s%s ", icon, name)
	end,

	hl = function(self)
		return {
			fg = mode_colors[self.mode] or colors.blue,
			bold = true,
		}
	end,

	update = {
		"ModeChanged",
		pattern = "*:*",
		callback = vim.schedule_wrap(function()
			vim.cmd.redrawstatus()
		end),
	},
}

--------------------------------------------------------------------------------
-- FILE
--------------------------------------------------------------------------------

local FileName = {
	provider = function()
		local name = vim.fn.expand("%:.")
		if name == "" then
			return "[No Name]"
		end
		return name
	end,

	hl = { bold = true },
}

local FileFlags = {
	provider = function()
		local flags = {}

		if vim.bo.modified then
			table.insert(flags, "[+]")
		end

		if vim.bo.readonly then
			table.insert(flags, "[RO]")
		end

		return (#flags > 0) and (" " .. table.concat(flags, " ")) or ""
	end,

	hl = { fg = colors.yellow },
}

--------------------------------------------------------------------------------
-- GIT
--------------------------------------------------------------------------------

local Git = {
	condition = conditions.is_git_repo,

	init = function(self)
		self.status_dict = vim.b.gitsigns_status_dict
	end,

	provider = function(self)
		return "  " .. self.status_dict.head .. " "
	end,

	hl = { fg = colors.orange },
}

--------------------------------------------------------------------------------
-- SEARCH COUNT
--------------------------------------------------------------------------------

local SearchCount = {
	condition = function()
		return vim.v.hlsearch ~= 0
	end,

	provider = function()
		local ok, result = pcall(vim.fn.searchcount, { recompute = 1 })

		if not ok or result.total == 0 then
			return ""
		end

		return string.format(" / [%d/%d] ", result.current, result.total)
	end,

	hl = { fg = colors.cyan },
}

--------------------------------------------------------------------------------
-- MACRO
--------------------------------------------------------------------------------

local MacroRec = {
	condition = function()
		return vim.fn.reg_recording() ~= ""
	end,

	provider = function()
		return " REC @" .. vim.fn.reg_recording() .. " "
	end,

	hl = {
		fg = colors.red,
		bold = true,
	},

	update = {
		"RecordingEnter",
		"RecordingLeave",
	},
}

--------------------------------------------------------------------------------
-- FILETYPE
--------------------------------------------------------------------------------

local FileType = {
	provider = function()
		return " " .. vim.bo.filetype .. " "
	end,

	hl = { fg = colors.green },
}

--------------------------------------------------------------------------------
-- RULER
--------------------------------------------------------------------------------

local Ruler = {
	provider = function()
		local current = vim.fn.line(".")
		local total = vim.fn.line("$")
		local percent = math.floor((current / total) * 100)

		return string.format(" %d:%d │ %d%% ", current, total, percent)
	end,
}

--------------------------------------------------------------------------------
-- ALIGN
--------------------------------------------------------------------------------

local Align = {
	provider = "%=",
}

--------------------------------------------------------------------------------
-- STATUSLINE
--------------------------------------------------------------------------------

local StatusLine = {
	Mode,
	{ provider = "│ " },

	FileName,
	FileFlags,

	Align,

	Git,
	SearchCount,
	MacroRec,

	FileType,
	{ provider = "│" },

	Ruler,
}

require("heirline").setup({
	statusline = StatusLine,
})
