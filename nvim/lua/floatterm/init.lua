-- lua/floatterm/init.lua
local M = {}

-- Plugin state
local state = {
	terminals = {},
	current_term = nil,
	main_win = nil,
	main_buf = nil,
	sidebar_win = nil,
	sidebar_buf = nil,
	is_open = false,
	next_id = 1,
}

-- Default configuration
local default_config = {
	width = 0.8,
	height = 0.8,
	sidebar_width = 0.25,
	border = "rounded",
	title = " 󰆍 FloatTerm ",
	sidebar_title = "  Terminals",
	transparency = true,
	blend = 10, -- 0-100, lower is more transparent
}

local config = default_config

-- Namespace for sidebar highlights
local ns = vim.api.nvim_create_namespace("floatterm_sidebar")

-- Utility functions
local function update_sidebar()
	if not state.sidebar_buf or not vim.api.nvim_buf_is_valid(state.sidebar_buf) then
		return
	end

	local lines = { "" }
	for _, term in ipairs(state.terminals) do
		local active = (term.id == (state.current_term and state.current_term.id))
		local name = term.name or ("Terminal " .. term.id)
		local indicator = active and "▶" or " "
		table.insert(lines, string.format(" %s %s", indicator, name))
	end

	table.insert(lines, "")
	table.insert(lines, " ─────────────────────")
	table.insert(lines, " 󰌑 <CR>  Switch")
	table.insert(lines, "  a    Add new")
	table.insert(lines, " 󰗨 d    Delete")
	table.insert(lines, " 󰑕 r    Rename")
	table.insert(lines, "  q    Close")
	table.insert(lines, "")

	vim.bo[state.sidebar_buf].modifiable = true
	vim.api.nvim_buf_set_lines(state.sidebar_buf, 0, -1, false, lines)
	vim.bo[state.sidebar_buf].modifiable = false

	-- Clear old highlights
	vim.api.nvim_buf_clear_namespace(state.sidebar_buf, ns, 0, -1)

	-- Highlight active/inactive
	for i, term in ipairs(state.terminals) do
		local lnum = i -- offset by 1 because of first empty line
		if term.id == (state.current_term and state.current_term.id) then
			vim.api.nvim_buf_add_highlight(state.sidebar_buf, ns, "String", lnum, 0, -1)
		else
			vim.api.nvim_buf_add_highlight(state.sidebar_buf, ns, "Comment", lnum, 0, -1)
		end
	end

	-- Highlight help section
	local help_start = #state.terminals + 2
	for i = help_start, #lines do
		vim.api.nvim_buf_add_highlight(state.sidebar_buf, ns, "Keyword", i, 0, -1)
	end
end

local function get_selected_terminal()
	if not state.sidebar_win or not vim.api.nvim_win_is_valid(state.sidebar_win) then
		return nil
	end
	local cursor_line = vim.api.nvim_win_get_cursor(state.sidebar_win)[1]
	local term_line = cursor_line - 1 -- because of initial empty line
	if term_line >= 1 and term_line <= #state.terminals then
		return state.terminals[term_line], term_line
	end
	return nil, nil
end

local function setup_sidebar_keymaps()
	local buf = state.sidebar_buf
	local opts = { buffer = buf, silent = true }

	vim.keymap.set("n", "<CR>", function()
		local term, _ = get_selected_terminal()
		if term then
			M.switch_terminal(term.id)
		end
	end, opts)

	vim.keymap.set("n", "a", function()
		M.add_terminal()
	end, opts)

	vim.keymap.set("n", "d", function()
		local term, _ = get_selected_terminal()
		if term then
			M.delete_terminal(term.id)
		end
	end, opts)

	vim.keymap.set("n", "r", function()
		local term, _ = get_selected_terminal()
		if term then
			local new_name = vim.fn.input("New name: ", term.name)
			if new_name and new_name ~= "" then
				term.name = new_name
				update_sidebar()
			end
		end
	end, opts)

	vim.keymap.set("n", "q", function()
		M.close()
	end, opts)

	vim.keymap.set("n", "<leader>tt", function()
		if state.main_win and vim.api.nvim_win_is_valid(state.main_win) then
			vim.api.nvim_set_current_win(state.main_win)
			vim.cmd("startinsert")
		end
	end, { buffer = buf, silent = true, desc = "Focus terminal window" })

	vim.keymap.set("n", "<C-w>t", function()
		if state.main_win and vim.api.nvim_win_is_valid(state.main_win) then
			vim.api.nvim_set_current_win(state.main_win)
			vim.cmd("startinsert")
		end
	end, { buffer = buf, silent = true, desc = "Focus terminal window" })
end

local function create_terminal(name)
	local term = {
		id = state.next_id,
		name = name or ("Terminal " .. state.next_id),
		buf = nil,
		job_id = nil,
	}
	state.next_id = state.next_id + 1
	table.insert(state.terminals, term)
	return term
end

local function switch_to_terminal(term)
	if not state.main_win or not vim.api.nvim_win_is_valid(state.main_win) then
		return
	end

	if not term.buf or not vim.api.nvim_buf_is_valid(term.buf) then
		term.buf = vim.api.nvim_create_buf(false, true)
		vim.bo[term.buf].bufhidden = "hide"
		vim.bo[term.buf].buftype = ""
	end

	vim.api.nvim_win_set_buf(state.main_win, term.buf)

	if not term.job_id then
		vim.api.nvim_set_current_win(state.main_win)
		term.job_id = vim.fn.termopen(config.shell or vim.o.shell, {
			on_exit = function(_, _, _)
				term.job_id = nil
				update_sidebar()
			end,
		})
		-- Auto cleanup when buffer is wiped
		vim.api.nvim_create_autocmd("BufWipeout", {
			buffer = term.buf,
			callback = function()
				term.job_id = nil
				update_sidebar()
			end,
			once = true,
		})
	end

	state.current_term = term
	update_sidebar()
	vim.api.nvim_set_current_win(state.main_win)
	if term.job_id then
		vim.cmd("startinsert")
	end
end

-- Public API
function M.setup(opts)
	config = vim.tbl_deep_extend("force", default_config, opts or {})
end

function M.toggle()
	if state.is_open then
		M.close()
	else
		M.open()
	end
end

function M.open()
	if state.is_open then
		return
	end
	local total_width = math.ceil(vim.o.columns * config.width)
	local height = math.ceil(vim.o.lines * config.height)
	local sidebar_width = math.ceil(total_width * config.sidebar_width)
	local main_width = total_width - sidebar_width
	local start_row = math.ceil((vim.o.lines - height) / 2)
	local start_col = math.ceil((vim.o.columns - total_width) / 2)

	local sidebar_buf = vim.api.nvim_create_buf(false, true)
	local sidebar_win = vim.api.nvim_open_win(sidebar_buf, false, {
		relative = "editor",
		width = sidebar_width,
		height = height,
		row = start_row,
		col = start_col,
		style = "minimal",
		border = config.border,
		title = config.sidebar_title,
		title_pos = "center",
	})
	if config.transparency then
		vim.wo[sidebar_win].winblend = config.blend
	end

	local main_buf = vim.api.nvim_create_buf(false, true)
	local main_win = vim.api.nvim_open_win(main_buf, true, {
		relative = "editor",
		width = main_width,
		height = height,
		row = start_row,
		col = start_col + sidebar_width,
		style = "minimal",
		border = config.border,
		title = config.title,
		title_pos = "center",
	})
	if config.transparency then
		vim.wo[main_win].winblend = config.blend
	end

	state.main_win, state.main_buf = main_win, main_buf
	state.sidebar_win, state.sidebar_buf = sidebar_win, sidebar_buf
	state.is_open = true

	vim.bo[sidebar_buf].bufhidden = "wipe"
	vim.bo[sidebar_buf].buftype = "nofile"
	vim.bo[sidebar_buf].swapfile = false
	vim.bo[sidebar_buf].modifiable = false
	vim.bo[sidebar_buf].filetype = "floatterm-sidebar"

	vim.wo[sidebar_win].wrap = false
	vim.wo[sidebar_win].cursorline = true
	vim.wo[sidebar_win].number = false
	vim.wo[sidebar_win].relativenumber = false
	vim.wo[sidebar_win].signcolumn = "no"
	vim.wo[main_win].number = false
	vim.wo[main_win].relativenumber = false
	vim.wo[main_win].signcolumn = "no"

	if #state.terminals == 0 then
		local term = create_terminal("Terminal 1")
		switch_to_terminal(term)
	else
		local term = state.current_term or state.terminals[1]
		switch_to_terminal(term)
	end

	setup_sidebar_keymaps()
	update_sidebar()

	if #state.terminals > 0 then
		vim.api.nvim_win_set_cursor(sidebar_win, { 2, 0 })
	end

	local main_opts = { buffer = main_buf, silent = true, desc = "Focus terminal sidebar" }
	vim.keymap.set("n", "<leader>ts", function()
		if state.sidebar_win and vim.api.nvim_win_is_valid(state.sidebar_win) then
			vim.api.nvim_set_current_win(state.sidebar_win)
		end
	end, main_opts)

	vim.keymap.set("t", "<leader>ts", function()
		vim.cmd("stopinsert")
		if state.sidebar_win and vim.api.nvim_win_is_valid(state.sidebar_win) then
			vim.api.nvim_set_current_win(state.sidebar_win)
		end
	end, main_opts)

	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(main_win),
		callback = function()
			M.close()
		end,
		once = true,
	})
end

function M.close()
	if not state.is_open then
		return
	end
	if state.main_win and vim.api.nvim_win_is_valid(state.main_win) then
		vim.api.nvim_win_close(state.main_win, true)
	end
	if state.sidebar_win and vim.api.nvim_win_is_valid(state.sidebar_win) then
		vim.api.nvim_win_close(state.sidebar_win, true)
	end
	state.main_win, state.main_buf = nil, nil
	state.sidebar_win, state.sidebar_buf = nil, nil
	state.is_open = false
end

function M.add_terminal(name)
	local term = create_terminal(name)
	if state.is_open then
		switch_to_terminal(term)
	end
	return term
end

function M.delete_terminal(id)
	for i, term in ipairs(state.terminals) do
		if term.id == id then
			if term.job_id then
				vim.fn.jobstop(term.job_id)
			end
			if term.buf and vim.api.nvim_buf_is_valid(term.buf) then
				vim.api.nvim_buf_delete(term.buf, { force = true })
			end
			table.remove(state.terminals, i)
			if state.current_term and state.current_term.id == id then
				if #state.terminals > 0 then
					local next_term = state.terminals[math.min(i, #state.terminals)]
					switch_to_terminal(next_term)
				else
					state.current_term = nil
				end
			end
			update_sidebar()
			break
		end
	end
end

function M.switch_terminal(id)
	for _, term in ipairs(state.terminals) do
		if term.id == id then
			switch_to_terminal(term)
			break
		end
	end
end

function M.list_terminals()
	return state.terminals
end

function M._get_state()
	return state
end

return M
