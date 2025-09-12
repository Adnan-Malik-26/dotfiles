local M = {}

-- Keep state so we can toggle
local state = {
	buf = -1,
	win = -1,
}

--- Open a centered floating terminal
---@param opts table|nil {width:number, height:number, winblend:number}
function M.open(opts)
	opts = opts or {}

	-- editor dimensions
	local cols, lines = vim.o.columns, vim.o.lines
	local top_offset = (vim.o.showtabline == 2) and 1 or 0
	local cmdheight = tonumber(vim.o.cmdheight) or 1
	local statusline = (vim.o.laststatus ~= 0) and 1 or 0
	local bottom_offset = cmdheight + statusline

	local avail_lines = lines - top_offset - bottom_offset

	-- size (default 80%)
	local width = opts.width or math.floor(cols * 0.8)
	local height = opts.height or math.floor(avail_lines * 0.8)

	-- centered position
	local row = top_offset + math.floor((avail_lines - height) / 2)
	local col = math.floor((cols - width) / 2)

	-- create buffer + window
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	})

	-- define highlights
	vim.api.nvim_set_hl(0, "Floaterminal", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "FloaterminalBorder", { bg = "NONE", fg = "#cba6f7" })

	-- apply window-local options
	vim.api.nvim_set_option_value("winhighlight", "Normal:Floaterminal,FloatBorder:FloaterminalBorder", { win = win })

	vim.api.nvim_set_option_value("winblend", opts.winblend or 20, { win = win })

	-- start terminal
	vim.fn.termopen(vim.o.shell)
	vim.cmd("startinsert")

	-- save state
	state.buf = buf
	state.win = win
end

--- Toggle the floating terminal
function M.toggle()
	if state.win ~= -1 and vim.api.nvim_win_is_valid(state.win) then
		vim.api.nvim_win_hide(state.win)
		state.win = -1
		state.buf = -1
	else
		M.open()
	end
end

-- user command
vim.api.nvim_create_user_command("Floaterminal", function()
	M.toggle()
end, {})

return M
