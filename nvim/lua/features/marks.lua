-- Custom Marks Feature with Virtual Text
local api = vim.api
local namespace = api.nvim_create_namespace("marks_virtual_text")

-- Set custom highlight for marks
api.nvim_set_hl(0, "MarksVirtualText", { fg = "#cba6f7" })

-- Path for persisting marks
local marks_file = vim.fn.stdpath("data") .. "/user_marks.json"

-- Load marks from disk
local function load_marks()
	local file = io.open(marks_file, "r")
	if file then
		local content = file:read("*all")
		file:close()
		local ok, data = pcall(vim.json.decode, content)
		if ok and data then
			return data
		end
	end
	return {}
end

-- Save marks to disk
local function save_marks(marks)
	local file = io.open(marks_file, "w")
	if file then
		file:write(vim.json.encode(marks))
		file:close()
	end
end

-- Track user-set marks
local user_marks = load_marks()

-- Function to update marks virtual text
local function update_marks_virtual_text()
	local bufnr = api.nvim_get_current_buf()
	local bufname = api.nvim_buf_get_name(bufnr)

	-- Clear existing virtual text
	api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)

	-- Only show marks that user has explicitly set for this buffer
	for mark_char, mark_info in pairs(user_marks) do
		if mark_info.bufname == bufname then
			local ok, pos = pcall(api.nvim_buf_get_mark, bufnr, mark_char)

			if ok and pos and pos[1] > 0 then
				local line = pos[1] - 1

				if line >= 0 and line < api.nvim_buf_line_count(bufnr) then
					api.nvim_buf_set_extmark(bufnr, namespace, line, 0, {
						virt_text = { { " 󰃀 " .. mark_char, "MarksVirtualText" } },
						virt_text_pos = "eol",
						priority = 100,
					})
				end
			end
		end
	end
end

-- Override the 'm' command to track user marks
local function set_mark(mark_char)
	vim.cmd("normal! m" .. mark_char)

	local pos = api.nvim_buf_get_mark(0, mark_char)
	local bufnr = api.nvim_get_current_buf()
	local bufname = api.nvim_buf_get_name(bufnr)

	user_marks[mark_char] = {
		bufnr = bufnr,
		bufname = bufname,
		line = pos[1],
		col = pos[2],
	}

	save_marks(user_marks)
	update_marks_virtual_text()
end

-- Override delmarks to track deletions
local function delete_marks(marks_str)
	vim.cmd("delmarks " .. marks_str)

	for mark_char in marks_str:gmatch(".") do
		user_marks[mark_char] = nil
	end

	save_marks(user_marks)
	update_marks_virtual_text()
end

-- Create commands for mark management
vim.api.nvim_create_user_command("Mark", function(opts)
	if opts.args and #opts.args == 1 then
		set_mark(opts.args)
	end
end, { nargs = 1, desc = "Set a mark and track it" })

vim.api.nvim_create_user_command("DelMarks", function(opts)
	if opts.args then
		delete_marks(opts.args)
	end
end, { nargs = 1, desc = "Delete marks and update tracking" })

vim.api.nvim_create_user_command("MarksRefresh", update_marks_virtual_text, {})

vim.api.nvim_create_user_command("MarksClear", function()
	user_marks = {}
	save_marks(user_marks)
	api.nvim_buf_clear_namespace(0, namespace, 0, -1)
end, { desc = "Clear all tracked marks" })

vim.api.nvim_create_user_command("MarksList", function()
	if vim.tbl_isempty(user_marks) then
		print("No marks set")
		return
	end

	print("Tracked marks:")
	for mark, info in pairs(user_marks) do
		print(string.format("  %s: %s (line %d)", mark, info.bufname, info.line))
	end
end, { desc = "List all tracked marks" })

-- Remap 'm' to use our tracking function
vim.keymap.set("n", "m", function()
	local char = vim.fn.getcharstr()
	if char:match("[a-zA-Z]") then
		set_mark(char)
	end
end, { noremap = true, silent = true, desc = "Set mark with tracking" })

-- Create autocommands to update marks
local marks_group = api.nvim_create_augroup("MarksVirtualText", { clear = true })

api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "BufReadPost" }, {
	group = marks_group,
	callback = function()
		vim.defer_fn(update_marks_virtual_text, 50)
	end,
})

api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
	group = marks_group,
	callback = update_marks_virtual_text,
})

-- Keymap to toggle marks visibility
local marks_visible = true
vim.keymap.set("n", "<leader>tm", function()
	if marks_visible then
		api.nvim_buf_clear_namespace(0, namespace, 0, -1)
	else
		update_marks_virtual_text()
	end
	marks_visible = not marks_visible
end, { noremap = true, silent = true, desc = "Toggle marks virtual text" })

-- Initial update
update_marks_virtual_text()
