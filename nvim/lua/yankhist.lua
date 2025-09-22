-- yankhist.lua
-- Enhanced Neovim plugin to store yank history with advanced features

local M = {}

-- Configuration
local config = {
	max_history = 50,
	keymap = "<leader>c",
	ignore_empty = true,
	ignore_single_char = true,
	session_based = true,
	project_based = true,
	auto_cleanup = {
		enabled = true,
		max_age_hours = 24,
		similarity_threshold = 0.9,
	},
	smart_indent = true,
	preview = {
		enabled = true,
		max_lines = 20,
		syntax_highlight = true,
	},
	icons = {
		text = "📝",
		code = "💾",
		json = "📋",
		url = "🔗",
		path = "📁",
		number = "🔢",
		multiline = "📄",
	},
}

-- Storage
local yank_history = {}
local sessions = {}
local current_session_id = nil
local current_project_root = nil

-- Utility functions
local function get_project_root()
	local cwd = vim.fn.getcwd()
	local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(cwd) .. " rev-parse --show-toplevel")[1]
	if vim.v.shell_error == 0 and git_root then
		return git_root
	end
	return cwd
end

local function generate_session_id()
	return tostring(os.time()) .. "_" .. math.random(1000, 9999)
end

local function detect_yank_type(text)
	-- Remove leading/trailing whitespace for analysis
	local trimmed = vim.trim(text)

	-- Check for various patterns
	if trimmed:match("^https?://") or trimmed:match("^ftp://") then
		return "url"
	elseif trimmed:match("^[%d%.%-]+$") then
		return "number"
	elseif trimmed:match("^[%w%._%-/\\]+%.[%w]+$") or trimmed:match("^[/\\]") then
		return "path"
	elseif trimmed:match("^%s*[{%[]") and trimmed:match("[}%]]%s*$") then
		return "json"
	elseif string.find(text, "\n") then
		return "multiline"
	elseif trimmed:match("^%s*[%w_]+%s*[%(=]") or trimmed:match("[;{}]%s*$") then
		return "code"
	else
		return "text"
	end
end

local function get_icon(yank_type)
	return config.icons[yank_type] or config.icons.text
end

local function calculate_similarity(str1, str2)
	local len1, len2 = #str1, #str2
	local matrix = {}

	for i = 0, len1 do
		matrix[i] = { [0] = i }
	end

	for j = 0, len2 do
		matrix[0][j] = j
	end

	for i = 1, len1 do
		for j = 1, len2 do
			local cost = (str1:sub(i, i) == str2:sub(j, j)) and 0 or 1
			matrix[i][j] = math.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost)
		end
	end

	local distance = matrix[len1][len2]
	local max_len = math.max(len1, len2)
	return max_len > 0 and (1 - distance / max_len) or 1
end

local function auto_cleanup_history()
	if not config.auto_cleanup.enabled then
		return
	end

	local current_time = os.time()
	local cutoff_time = current_time - (config.auto_cleanup.max_age_hours * 3600)

	-- Remove old entries
	for i = #yank_history, 1, -1 do
		if yank_history[i].timestamp < cutoff_time then
			table.remove(yank_history, i)
		end
	end

	-- Remove similar entries
	for i = #yank_history, 2, -1 do
		for j = i - 1, 1, -1 do
			local similarity = calculate_similarity(yank_history[i].text, yank_history[j].text)
			if similarity >= config.auto_cleanup.similarity_threshold then
				table.remove(yank_history, i)
				break
			end
		end
	end
end

local function get_file_type(filename)
	if not filename then
		return "text"
	end
	local ext = filename:match("%.([^%.]+)$")
	if not ext then
		return "text"
	end

	local ft_map = {
		lua = "lua",
		py = "python",
		js = "javascript",
		ts = "typescript",
		html = "html",
		css = "css",
		json = "json",
		xml = "xml",
		md = "markdown",
		txt = "text",
		vim = "vim",
		sh = "bash",
	}

	return ft_map[ext] or ext
end

local function smart_indent_text(text, target_indent)
	if not config.smart_indent then
		return text
	end

	local lines = vim.split(text, "\n")
	if #lines <= 1 then
		return text
	end

	-- Find minimum indentation
	local min_indent = math.huge
	for i, line in ipairs(lines) do
		if line:match("%S") then -- non-empty line
			local indent = line:match("^%s*"):len()
			min_indent = math.min(min_indent, indent)
		end
	end

	if min_indent == math.huge then
		return text
	end

	-- Adjust indentation
	local adjusted_lines = {}
	for i, line in ipairs(lines) do
		if line:match("%S") then
			local current_indent = line:match("^%s*"):len()
			local new_indent = target_indent + (current_indent - min_indent)
			adjusted_lines[i] = string.rep(" ", new_indent) .. line:match("^%s*(.*)$")
		else
			adjusted_lines[i] = ""
		end
	end

	return table.concat(adjusted_lines, "\n")
end

-- Session management
local function init_session()
	current_session_id = generate_session_id()
	current_project_root = config.project_based and get_project_root() or nil

	if config.session_based then
		sessions[current_session_id] = {
			history = {},
			project_root = current_project_root,
			created_at = os.time(),
		}
		yank_history = sessions[current_session_id].history
	end
end

local function get_current_history()
	if config.project_based and current_project_root then
		-- Find history for current project across all sessions
		local project_history = {}
		for _, session in pairs(sessions) do
			if session.project_root == current_project_root then
				vim.list_extend(project_history, session.history)
			end
		end
		-- Sort by timestamp
		table.sort(project_history, function(a, b)
			return a.timestamp > b.timestamp
		end)
		return project_history
	elseif config.session_based then
		return sessions[current_session_id] and sessions[current_session_id].history or {}
	else
		return yank_history
	end
end

-- Setup function
function M.setup(opts)
	opts = opts or {}
	config = vim.tbl_deep_extend("force", config, opts)

	init_session()

	-- Create autocommand to capture yanks
	vim.api.nvim_create_augroup("YankHistory", { clear = true })
	vim.api.nvim_create_autocmd("TextYankPost", {
		group = "YankHistory",
		callback = function()
			local yanked_text = vim.fn.getreg('"')
			M.add_to_history(yanked_text)
		end,
	})

	-- Auto cleanup timer
	if config.auto_cleanup.enabled then
		vim.defer_fn(function()
			auto_cleanup_history()
		end, 60000) -- Run every minute
	end

	-- Project change detection
	if config.project_based then
		vim.api.nvim_create_autocmd({ "DirChanged", "VimEnter" }, {
			group = "YankHistory",
			callback = function()
				local new_root = get_project_root()
				if new_root ~= current_project_root then
					current_project_root = new_root
					if config.session_based and sessions[current_session_id] then
						sessions[current_session_id].project_root = new_root
					end
				end
			end,
		})
	end

	-- Set up keymap
	vim.keymap.set("n", config.keymap, M.show_telescope, { desc = "Show yank history" })
end

-- Add text to yank history
function M.add_to_history(text)
	-- Skip if empty and ignore_empty is true
	if config.ignore_empty and (text == "" or text == nil) then
		return
	end

	-- Skip single character yanks if ignore_single_char is true
	if config.ignore_single_char and string.len(text) == 1 then
		return
	end

	local current_buf = vim.api.nvim_get_current_buf()
	local buf_name = vim.api.nvim_buf_get_name(current_buf)
	local cursor_pos = vim.api.nvim_win_get_cursor(0)

	local entry = {
		text = text,
		timestamp = os.time(),
		source_file = buf_name,
		source_line = cursor_pos[1],
		source_col = cursor_pos[2],
		filetype = get_file_type(buf_name),
		yank_type = detect_yank_type(text),
		project_root = current_project_root,
		session_id = current_session_id,
	}

	local target_history = config.session_based and sessions[current_session_id].history or yank_history

	-- Remove if already exists to avoid duplicates
	for i, existing_entry in ipairs(target_history) do
		if existing_entry.text == text then
			table.remove(target_history, i)
			break
		end
	end

	-- Add to front of history
	table.insert(target_history, 1, entry)

	-- Limit history size
	if #target_history > config.max_history then
		target_history[config.max_history + 1] = nil
	end

	-- Run auto cleanup periodically
	if math.random() < 0.1 then -- 10% chance
		auto_cleanup_history()
	end
end

-- Format entry for telescope display
local function format_entry(entry)
	local text = entry.text
	local timestamp = os.date("%H:%M:%S", entry.timestamp)
	local icon = get_icon(entry.yank_type)
	local source = entry.source_file and vim.fn.fnamemodify(entry.source_file, ":t") or "unknown"

	-- Replace newlines with visible character for display
	local display_text = text:gsub("\n", "↵"):gsub("\t", "→")

	-- Truncate if too long
	if string.len(display_text) > 60 then
		display_text = string.sub(display_text, 1, 57) .. "..."
	end

	return string.format("%s [%s] %s (%s)", icon, timestamp, display_text, source)
end

-- Enhanced telescope integration with preview and multi-select
function M.show_telescope()
	local has_telescope, telescope = pcall(require, "telescope")
	if not has_telescope then
		vim.notify("Telescope is required for yank history", vim.log.levels.ERROR)
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")

	local history = get_current_history()

	if #history == 0 then
		vim.notify("No yank history available", vim.log.levels.INFO)
		return
	end

	-- Custom previewer
	local previewer = nil
	if config.preview.enabled then
		previewer = previewers.new_buffer_previewer({
			title = "Yank Preview",
			define_preview = function(self, entry)
				local lines = vim.split(entry.value.text, "\n")
				local preview_lines = {}

				for i, line in ipairs(lines) do
					if i > config.preview.max_lines then
						table.insert(preview_lines, "... (" .. (#lines - i + 1) .. " more lines)")
						break
					end
					table.insert(preview_lines, line)
				end

				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)

				if config.preview.syntax_highlight and entry.value.filetype then
					vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", entry.value.filetype)
				end

				-- Add metadata at the bottom
				local metadata = {
					"",
					"--- Metadata ---",
					"Source: " .. (entry.value.source_file or "unknown"),
					"Line: " .. (entry.value.source_line or "unknown"),
					"Type: " .. entry.value.yank_type,
					"Size: " .. string.len(entry.value.text) .. " chars, " .. #lines .. " lines",
					"Time: " .. os.date("%Y-%m-%d %H:%M:%S", entry.value.timestamp),
				}

				vim.api.nvim_buf_set_lines(self.state.bufnr, #preview_lines, -1, false, metadata)
			end,
		})
	end

	local picker = pickers.new({}, {
		prompt_title = "Yank History"
			.. (current_project_root and " (" .. vim.fn.fnamemodify(current_project_root, ":t") .. ")" or ""),
		finder = finders.new_table({
			results = history,
			entry_maker = function(entry)
				return {
					value = entry,
					display = format_entry(entry),
					ordinal = entry.text .. " " .. (entry.source_file or ""),
				}
			end,
		}),
		sorter = conf.generic_sorter({}),
		previewer = previewer,
		attach_mappings = function(prompt_bufnr, map)
			local multi_selections = {}

			-- Default action - paste single selection
			actions.select_default:replace(function()
				local selections = {}

				-- Check for multi-selections first
				local picker_state = action_state.get_current_picker(prompt_bufnr)
				if picker_state.multi and #picker_state.multi._entries > 0 then
					for _, entry in pairs(picker_state.multi._entries) do
						table.insert(selections, entry)
					end
				else
					-- Single selection
					local selection = action_state.get_selected_entry()
					if selection then
						table.insert(selections, selection)
					end
				end

				actions.close(prompt_bufnr)

				if #selections > 0 then
					M.paste_selections(selections)
				end
			end)

			-- Toggle selection for multi-select
			map("i", "<Tab>", actions.toggle_selection + actions.move_selection_worse)
			map("n", "<Tab>", actions.toggle_selection + actions.move_selection_worse)

			-- Select all
			map("i", "<C-a>", actions.select_all)
			map("n", "<C-a>", actions.select_all)

			-- Delete entry
			map("i", "<C-d>", function()
				local selection = action_state.get_selected_entry()
				if selection then
					M.delete_entry(selection.value)
					actions.close(prompt_bufnr)
					vim.notify("Deleted entry from yank history", vim.log.levels.INFO)
					vim.defer_fn(function()
						M.show_telescope()
					end, 100)
				end
			end)

			return true
		end,
	})

	picker:find()
end

-- Paste multiple selections
function M.paste_selections(selections)
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local current_indent = vim.fn.indent(cursor_pos[1])

	-- Sort selections by their original order if multiple
	table.sort(selections, function(a, b)
		return a.value.timestamp > b.value.timestamp
	end)

	local paste_texts = {}
	for _, selection in ipairs(selections) do
		local text = selection.value.text
		if config.smart_indent then
			text = smart_indent_text(text, current_indent)
		end
		table.insert(paste_texts, text)
	end

	-- Join all selections and paste
	local combined_text = table.concat(paste_texts, "\n")
	vim.fn.setreg('"', combined_text)
	vim.cmd("normal! p")

	vim.notify("Pasted " .. #selections .. " entries", vim.log.levels.INFO)
end

-- Delete entry from history
function M.delete_entry(entry_to_delete)
	local history = config.session_based and sessions[current_session_id].history or yank_history

	for i, entry in ipairs(history) do
		if entry.text == entry_to_delete.text and entry.timestamp == entry_to_delete.timestamp then
			table.remove(history, i)
			break
		end
	end
end

-- Get yank history
function M.get_history()
	return get_current_history()
end

-- Clear yank history
function M.clear_history()
	if config.session_based then
		if sessions[current_session_id] then
			sessions[current_session_id].history = {}
		end
	else
		yank_history = {}
	end
end

-- Get session info
function M.get_session_info()
	return {
		current_session = current_session_id,
		project_root = current_project_root,
		total_sessions = vim.tbl_count(sessions),
		current_history_size = #get_current_history(),
	}
end

-- Commands
vim.api.nvim_create_user_command("YankHistory", M.show_telescope, { desc = "Show yank history" })
vim.api.nvim_create_user_command("YankHistoryClear", M.clear_history, { desc = "Clear yank history" })
vim.api.nvim_create_user_command("YankHistoryInfo", function()
	local info = M.get_session_info()
	print(vim.inspect(info))
end, { desc = "Show yank history info" })

return M
