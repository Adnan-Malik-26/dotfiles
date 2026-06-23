-- statusline.lua
-- Custom Neovim statusline — pure Lua, single file.
-- External dependency: nvim-web-devicons (optional, graceful fallback)
-- Compatible with Neovim 0.12+

--------------------------------------------------------------------------------
-- HIGHLIGHTS
--------------------------------------------------------------------------------

local function setup_highlights()
	local hl = vim.api.nvim_set_hl

	-- Base palette
	local p = {
		bgd = "#1a1b26", -- darkest background
		bg = "#24283b", -- main background
		fg = "#c0caf5", -- foreground
		black = "#15161e",
		red = "#f7768e",
		green = "#9ece6a",
		yellow = "#e0af68",
		blue = "#7aa2f7",
		magenta = "#bb9af7",
		cyan = "#7dcfff",
		white = "#a9b1d6",
		orange = "#ff9e64",
		bright_black = "#414868",
		bright_white = "#c0caf5",
	}

	-- Active statusline base
	hl(0, "SLBase", { fg = p.fg, bg = p.bgd })
	hl(0, "SLSep", { fg = p.bright_black, bg = p.bgd })

	-- Mode highlights
	hl(0, "SLModeNormal", { fg = p.bgd, bg = p.blue, bold = true })
	hl(0, "SLModeInsert", { fg = p.bgd, bg = p.green, bold = true })
	hl(0, "SLModeVisual", { fg = p.bgd, bg = p.magenta, bold = true })
	hl(0, "SLModeReplace", { fg = p.bgd, bg = p.red, bold = true })
	hl(0, "SLModeCommand", { fg = p.bgd, bg = p.yellow, bold = true })
	hl(0, "SLModeTerminal", { fg = p.bgd, bg = p.orange, bold = true })

	-- Section highlights
	hl(0, "SLFile", { fg = p.fg, bg = p.bgd })
	hl(0, "SLModified", { fg = p.green, bg = p.bgd })
	hl(0, "SLReadOnly", { fg = p.red, bg = p.bgd })
	hl(0, "SLGit", { fg = p.green, bg = p.bgd })
	hl(0, "SLSearch", { fg = p.cyan, bg = p.bgd })
	hl(0, "SLMacro", { fg = p.orange, bg = p.bgd })
	hl(0, "SLVenv", { fg = p.yellow, bg = p.bgd })
	hl(0, "SLFiletype", { fg = p.blue, bg = p.bgd })
	hl(0, "SLPosition", { fg = p.bright_white, bg = p.bgd })
	hl(0, "SLPercent", { fg = p.fg, bg = p.bgd })

	-- Inactive statusline
	hl(0, "SLInactiveBase", { fg = p.bright_black, bg = p.bgd })
	hl(0, "SLInactiveFile", { fg = p.bright_black, bg = p.bgd })
	hl(0, "SLInactivePosition", { fg = p.bright_black, bg = p.bgd })
end

--------------------------------------------------------------------------------
-- UTILITY
--------------------------------------------------------------------------------

-- Wrap text in a statusline highlight group
local function hl(group, text)
	return string.format("%%#%s#%s%%#SLBase#", group, text)
end

-- Safe spacer
local function sp(n)
	return string.rep(" ", n or 1)
end

--------------------------------------------------------------------------------
-- GIT BRANCH (cached per buffer)
--------------------------------------------------------------------------------

-- Cache: bufnr → { branch, mtime }
local _git_cache = {}

local function get_git_branch()
	local bufnr = vim.api.nvim_get_current_buf()
	local bufname = vim.api.nvim_buf_get_name(bufnr)

	-- Derive directory from buffer path; fall back to cwd
	local dir = bufname ~= "" and vim.fn.fnamemodify(bufname, ":h") or vim.fn.getcwd()

	-- Use cached value if available and < 5s old
	local cached = _git_cache[bufnr]
	if cached and (vim.loop.now() - cached.ts) < 5000 then
		return cached.branch
	end

	-- Run git asynchronously via jobstart; fall back to synchronous for simplicity
	-- Using vim.fn.system here is acceptable because it is called infrequently and
	-- cached aggressively. A jobstart approach would require callback-based updates.
	local result =
		vim.fn.system(string.format("git -C %s rev-parse --abbrev-ref HEAD 2>/dev/null", vim.fn.shellescape(dir)))
	result = result:gsub("%s+$", "") -- strip trailing whitespace/newline

	local branch = (vim.v.shell_error == 0 and result ~= "") and result or nil
	_git_cache[bufnr] = { branch = branch, ts = vim.loop.now() }
	return branch
end

-- Invalidate cache for a given buffer
local function invalidate_git_cache(bufnr)
	_git_cache[bufnr or vim.api.nvim_get_current_buf()] = nil
end

--------------------------------------------------------------------------------
-- MODE
--------------------------------------------------------------------------------

local MODE_MAP = {
	n = { label = "NORMAL", hl = "SLModeNormal", icon = "󰆍" },
	i = { label = "INSERT", hl = "SLModeInsert", icon = "󰏫" },
	v = { label = "VISUAL", hl = "SLModeVisual", icon = "󰈈" },
	V = { label = "V-LINE", hl = "SLModeVisual", icon = "󰈈" },
	["\22"] = { label = "V-BLOCK", hl = "SLModeVisual", icon = "󰈈" },
	R = { label = "REPLACE", hl = "SLModeReplace", icon = "󰊄" },
	c = { label = "COMMAND", hl = "SLModeCommand", icon = "󰘳" },
	t = { label = "TERMINAL", hl = "SLModeTerminal", icon = "󰞷" },
	s = { label = "SELECT", hl = "SLModeVisual", icon = "󰈈" },
	S = { label = "S-LINE", hl = "SLModeVisual", icon = "󰈈" },
	["\19"] = { label = "S-BLOCK", hl = "SLModeVisual", icon = "󰈈" },
}

local function section_mode()
	local raw = vim.api.nvim_get_mode().mode
	-- Normalise multi-char modes (e.g. "no", "niI") to their base character
	local mode = MODE_MAP[raw] and raw or raw:sub(1, 1)
	local m = MODE_MAP[mode] or { label = raw:upper(), hl = "SLModeNormal", icon = "" }
	return hl(m.hl, string.format(" %s %s ", m.icon, m.label))
end

--------------------------------------------------------------------------------
-- FILENAME
--------------------------------------------------------------------------------

-- Attempt to load nvim-web-devicons; cache the module reference
local _devicons = nil
local _devicons_loaded = false
local function get_devicons()
	if not _devicons_loaded then
		local ok, di = pcall(require, "nvim-web-devicons")
		_devicons = ok and di or nil
		_devicons_loaded = true
	end
	return _devicons
end

local function section_filename()
	local bufname = vim.api.nvim_buf_get_name(0)
	local fname = bufname ~= "" and vim.fn.fnamemodify(bufname, ":t") or "[No Name]"
	local ext = fname:match("%.([^%.]+)$") or ""

	-- Icon from devicons
	local icon = ""
	local di = get_devicons()
	if di then
		local ic, _ = di.get_icon(fname, ext, { default = true })
		icon = (ic and ic ~= "") and (ic .. " ") or ""
	end

	-- Modified / readonly flags
	local flags = ""
	if vim.bo.modified then
		flags = flags .. hl("SLModified", " +")
	end
	if vim.bo.readonly then
		flags = flags .. hl("SLReadOnly", " ")
	end

	return hl("SLFile", sp() .. icon .. fname) .. flags .. sp()
end

--------------------------------------------------------------------------------
-- GIT BRANCH
--------------------------------------------------------------------------------

local function section_git()
	local branch = get_git_branch()
	if not branch then
		return ""
	end
	return hl("SLGit", sp() .. " " .. branch .. sp())
end

--------------------------------------------------------------------------------
-- SEARCH COUNT
--------------------------------------------------------------------------------

local function section_search()
	-- Only show when hlsearch is active
	if not vim.v.hlsearch or vim.v.hlsearch == 0 then
		return ""
	end

	local ok, sc = pcall(vim.fn.searchcount, { recompute = false, maxcount = 9999 })
	if not ok or not sc or sc.total == 0 then
		return ""
	end

	local current = sc.current or 0
	local total = sc.total or 0
	return hl("SLSearch", string.format(" %d/%d ", current, total))
end

--------------------------------------------------------------------------------
-- MACRO RECORDING
--------------------------------------------------------------------------------

local function section_macro()
	local reg = vim.fn.reg_recording()
	if reg == "" then
		return ""
	end
	return hl("SLMacro", string.format(" REC @%s ", reg))
end

--------------------------------------------------------------------------------
-- PYTHON VENV
--------------------------------------------------------------------------------

local function section_venv()
	local venv = vim.env.VIRTUAL_ENV
	if not venv or venv == "" then
		return ""
	end
	-- Show only the directory name of the venv path
	local name = vim.fn.fnamemodify(venv, ":t")
	return hl("SLVenv", string.format(" (%s) ", name))
end

--------------------------------------------------------------------------------
-- FILETYPE
--------------------------------------------------------------------------------

local function section_filetype()
	local ft = vim.bo.filetype
	if not ft or ft == "" then
		return ""
	end
	return hl("SLFiletype", sp() .. ft .. sp())
end

--------------------------------------------------------------------------------
-- CURSOR POSITION
--------------------------------------------------------------------------------

local function section_position()
	local line = vim.fn.line(".")
	local total = vim.api.nvim_buf_line_count(0)
	return hl("SLPosition", string.format(" %d/%d ", line, total))
end

--------------------------------------------------------------------------------
-- PERCENTAGE
--------------------------------------------------------------------------------

local function section_percent()
	local line = vim.fn.line(".")
	local total = vim.fn.line("$")
	if total == 0 then
		return ""
	end
	local pct = math.floor(line / total * 100)
	return hl("SLPercent", string.format("%d%%%% ", pct))
end

--------------------------------------------------------------------------------
-- ACTIVE STATUSLINE BUILDER
--------------------------------------------------------------------------------

local function build_active()
	local left = table.concat({
		section_mode(),
		section_filename(),
		section_git(),
	})

	local right = table.concat({
		section_search(),
		section_macro(),
		section_venv(),
		section_filetype(),
		section_position(),
		section_percent(),
	})

	-- %#SLBase# resets background for the whole line first
	return "%#SLBase#" .. left .. "%=" .. right
end

--------------------------------------------------------------------------------
-- INACTIVE STATUSLINE BUILDER
--------------------------------------------------------------------------------

local function build_inactive()
	local bufname = vim.api.nvim_buf_get_name(0)
	local fname = bufname ~= "" and vim.fn.fnamemodify(bufname, ":t") or "[No Name]"

	local left = hl("SLInactiveFile", sp() .. fname .. sp())
	local right = hl("SLInactivePosition", string.format(" %d/%d ", vim.fn.line("."), vim.api.nvim_buf_line_count(0)))

	return "%#SLInactiveBase#" .. left .. "%=" .. right
end

--------------------------------------------------------------------------------
-- STATUSLINE FUNCTION (called by Neovim on every redraw)
--------------------------------------------------------------------------------

-- Stored as a global function so %!v:lua.StatuslineRender() can reference it.
-- The namespace avoids polluting _G beyond a single key.
_G._SL = {}

function _G._SL.render()
	local winnr = vim.g.statusline_winid
	local cur = vim.api.nvim_get_current_win()

	if winnr and winnr ~= cur then
		return build_inactive()
	end

	return build_active()
end

--------------------------------------------------------------------------------
-- AUTOCMDS
--------------------------------------------------------------------------------

local function setup_autocmds()
	local group = vim.api.nvim_create_augroup("CustomStatusline", { clear = true })

	-- Redraw statusline on relevant events
	local redraw_events = {
		"ModeChanged",
		"BufEnter",
		"BufWritePost",
		"BufModifiedSet",
		"CursorMoved",
		"CursorMovedI",
		"CmdlineLeave",
		"WinEnter",
		"WinLeave",
		"RecordingEnter",
		"RecordingLeave",
	}
	vim.api.nvim_create_autocmd(redraw_events, {
		group = group,
		callback = function()
			vim.cmd.redrawstatus()
		end,
	})

	-- Re-apply highlights when colorscheme changes
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = setup_highlights,
	})

	-- Invalidate git cache on buffer write or directory change
	vim.api.nvim_create_autocmd({ "BufWritePost", "DirChanged" }, {
		group = group,
		callback = function(ev)
			invalidate_git_cache(ev.buf)
		end,
	})
end

--------------------------------------------------------------------------------
-- SETUP
--------------------------------------------------------------------------------

local function setup()
	setup_highlights()
	setup_autocmds()

	-- Use a statusline expression that calls our Lua render function
	vim.o.statusline = "%!v:lua._SL.render()"

	-- Show statusline always (2 = always, even with single window)
	vim.o.laststatus = 2

	-- Disable the default mode indicator in the command area (mode shown in SL)
	vim.o.showmode = false
end

setup()

--------------------------------------------------------------------------------
-- HOW TO LOAD FROM init.lua
--
--   -- Assuming the file lives at ~/.config/nvim/lua/statusline.lua:
--   require("statusline")
--
--   -- Or if placed directly under the Neovim config root:
--   vim.cmd("luafile " .. vim.fn.stdpath("config") .. "/statusline.lua")
--
--   No additional configuration is required.
--   nvim-web-devicons is used automatically if it is already loaded.
--------------------------------------------------------------------------------
