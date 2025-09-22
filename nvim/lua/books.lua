-- books.lua
-- Persistent bookmark manager with project and session awareness

local M = {}

-- Configuration
local config = {
	keymap_add = "<leader>ba",
	keymap_list = "<leader>bl",
	keymap_project = "<leader>bp",
	keymap_session = "<leader>bs",
	keymap_global = "<leader>bg",
	keymap_delete = "<leader>bd",

	-- Storage settings
	data_path = vim.fn.stdpath("data") .. "/bookmarks.json",
	auto_save = true,

	-- Display settings
	show_line_numbers = true,
	show_file_icons = true,
	show_relative_paths = true,
	max_description_length = 50,

	-- Organization
	project_based = true,
	session_based = true,
	auto_cleanup = true, -- Remove bookmarks for deleted files

	-- Categories
	default_categories = {
		"TODO",
		"FIXME",
		"NOTE",
		"IMPORTANT",
		"REFERENCE",
	},

	-- Icons
	icons = {
		bookmark = "🔖",
		file = "📄",
		line = "📍",
		project = "📁",
		session = "💻",
		category = "🏷️",
		default = "•",
	},

	-- Preview settings
	preview = {
		enabled = true,
		context_lines = 5, -- Lines before/after bookmark
		syntax_highlight = true,
	},
}

-- State management
local state = {
	bookmarks = {},
	current_project = nil,
	current_session = nil,
	loaded = false,
}

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
	return vim.fn.fnamemodify(vim.v.servername or "nvim", ":t") .. "_" .. os.time()
end

local function get_relative_path(filepath, base_path)
	if not base_path then
		return filepath
	end

	local rel_path = filepath:gsub("^" .. vim.pesc(base_path) .. "/", "")
	if rel_path ~= filepath then
		return rel_path
	end

	-- Try with home directory
	local home = vim.fn.expand("~")
	rel_path = filepath:gsub("^" .. vim.pesc(home), "~")
	return rel_path
end

local function load_bookmarks()
	if state.loaded then
		return
	end

	local file = io.open(config.data_path, "r")
	if file then
		local content = file:read("*all")
		file:close()

		local ok, data = pcall(vim.json.decode, content)
		if ok and data then
			state.bookmarks = data.bookmarks or {}
		end
	end

	state.loaded = true
end

local function save_bookmarks()
	if not config.auto_save then
		return
	end

	local data = {
		bookmarks = state.bookmarks,
		saved_at = os.time(),
		version = "1.0",
	}

	-- Create directory if it doesn't exist
	local dir = vim.fn.fnamemodify(config.data_path, ":h")
	vim.fn.mkdir(dir, "p")

	local file = io.open(config.data_path, "w")
	if file then
		file:write(vim.json.encode(data))
		file:close()
	end
end

local function cleanup_bookmarks()
	if not config.auto_cleanup then
		return
	end

	local updated = false
	for i = #state.bookmarks, 1, -1 do
		local bookmark = state.bookmarks[i]
		if not vim.fn.filereadable(bookmark.filepath) then
			table.remove(state.bookmarks, i)
			updated = true
		end
	end

	if updated then
		save_bookmarks()
	end
end

local function get_bookmark_id(filepath, line_num, column)
	return filepath .. ":" .. line_num .. ":" .. (column or 0)
end

local function create_bookmark(filepath, line_num, column, description, category)
	local current_project = config.project_based and get_project_root() or nil
	local current_session = config.session_based and generate_session_id() or nil

	return {
		id = get_bookmark_id(filepath, line_num, column),
		filepath = filepath,
		filename = vim.fn.fnamemodify(filepath, ":t"),
		line_num = line_num,
		column = column or 0,
		description = description or "",
		category = category or "",
		project_root = current_project,
		session_id = current_session,
		created_at = os.time(),
		filetype = vim.filetype.match({ filename = filepath }) or "text",
	}
end

-- Core bookmark functions
function M.setup(opts)
	opts = opts or {}
	config = vim.tbl_deep_extend("force", config, opts)

	-- Initialize state
	state.current_project = config.project_based and get_project_root() or nil
	state.current_session = config.session_based and generate_session_id() or nil

	-- Load existing bookmarks
	load_bookmarks()

	-- Clean up invalid bookmarks
	cleanup_bookmarks()

	-- Set up keymaps
	vim.keymap.set("n", config.keymap_add, M.add_bookmark, { desc = "Add bookmark" })
	vim.keymap.set("n", config.keymap_list, M.show_bookmarks, { desc = "Show all bookmarks" })
	vim.keymap.set("n", config.keymap_project, M.show_project_bookmarks, { desc = "Show project bookmarks" })
	vim.keymap.set("n", config.keymap_session, M.show_session_bookmarks, { desc = "Show session bookmarks" })
	vim.keymap.set("n", config.keymap_global, M.show_global_bookmarks, { desc = "Show global bookmarks" })
	vim.keymap.set("n", config.keymap_delete, M.delete_bookmark_at_cursor, { desc = "Delete bookmark at cursor" })

	-- Auto-save on exit
	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			save_bookmarks()
		end,
	})

	-- Project change detection
	if config.project_based then
		vim.api.nvim_create_autocmd({ "DirChanged", "VimEnter" }, {
			callback = function()
				state.current_project = get_project_root()
			end,
		})
	end
end

function M.add_bookmark(description, category)
	load_bookmarks()

	local filepath = vim.fn.expand("%:p")
	if filepath == "" then
		vim.notify("Cannot bookmark: no file", vim.log.levels.ERROR)
		return
	end

	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local line_num = cursor_pos[1]
	local column = cursor_pos[2]

	-- Get description from user if not provided
	if not description then
		description = vim.fn.input("Bookmark description: ")
		if description == "" then
			-- Use line content as default description
			local line_content = vim.api.nvim_get_current_line()
			description = line_content:match("^%s*(.-)%s*$") -- Trim whitespace
			if #description > config.max_description_length then
				description = description:sub(1, config.max_description_length - 3) .. "..."
			end
		end
	end

	-- Get category if not provided
	if not category and #config.default_categories > 0 then
		local category_list = table.concat(config.default_categories, ", ")
		category = vim.fn.input("Category (" .. category_list .. "): ")
	end

	-- Check if bookmark already exists at this location
	local bookmark_id = get_bookmark_id(filepath, line_num, column)
	for i, existing in ipairs(state.bookmarks) do
		if existing.id == bookmark_id then
			-- Update existing bookmark
			existing.description = description
			existing.category = category
			existing.created_at = os.time()
			save_bookmarks()
			vim.notify("Updated bookmark: " .. description, vim.log.levels.INFO)
			return
		end
	end

	-- Create new bookmark
	local bookmark = create_bookmark(filepath, line_num, column, description, category)
	table.insert(state.bookmarks, bookmark)

	save_bookmarks()
	vim.notify("Added bookmark: " .. description, vim.log.levels.INFO)
end

function M.delete_bookmark_at_cursor()
	load_bookmarks()

	local filepath = vim.fn.expand("%:p")
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local line_num = cursor_pos[1]

	-- Find bookmark at current location
	for i, bookmark in ipairs(state.bookmarks) do
		if bookmark.filepath == filepath and bookmark.line_num == line_num then
			local desc = bookmark.description
			table.remove(state.bookmarks, i)
			save_bookmarks()
			vim.notify("Deleted bookmark: " .. desc, vim.log.levels.INFO)
			return
		end
	end

	vim.notify("No bookmark found at current location", vim.log.levels.WARN)
end

function M.get_bookmarks(filter_type)
	load_bookmarks()
	cleanup_bookmarks()

	local filtered = {}

	for _, bookmark in ipairs(state.bookmarks) do
		local include = true

		if filter_type == "project" and config.project_based then
			include = bookmark.project_root == state.current_project
		elseif filter_type == "session" and config.session_based then
			include = bookmark.session_id == state.current_session
		elseif filter_type == "global" then
			include = true
		end

		if include then
			table.insert(filtered, bookmark)
		end
	end

	-- Sort by creation time (newest first)
	table.sort(filtered, function(a, b)
		return a.created_at > b.created_at
	end)

	return filtered
end

local function format_bookmark_entry(bookmark)
	local icon = config.icons.bookmark
	local line_info = config.show_line_numbers and string.format("[%d] ", bookmark.line_num) or ""
	local filename = bookmark.filename

	-- Show relative path if configured
	local path_info = ""
	if config.show_relative_paths and bookmark.project_root then
		local rel_path = get_relative_path(bookmark.filepath, bookmark.project_root)
		if rel_path ~= bookmark.filename then
			path_info = " (" .. vim.fn.fnamemodify(rel_path, ":h") .. ")"
		end
	end

	-- Category info
	local category_info = bookmark.category ~= "" and string.format(" [%s]", bookmark.category) or ""

	-- Time info
	local time_info = os.date(" (%m/%d %H:%M)", bookmark.created_at)

	local description = bookmark.description
	if #description > config.max_description_length then
		description = description:sub(1, config.max_description_length - 3) .. "..."
	end

	return string.format(
		"%s %s%s%s%s%s - %s",
		icon,
		line_info,
		filename,
		path_info,
		category_info,
		time_info,
		description
	)
end

function M.show_telescope_bookmarks(bookmarks, title)
	local has_telescope, telescope = pcall(require, "telescope")
	if not has_telescope then
		vim.notify("Telescope is required for bookmark manager", vim.log.levels.ERROR)
		return
	end

	if #bookmarks == 0 then
		vim.notify("No bookmarks found", vim.log.levels.INFO)
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")

	-- Custom previewer
	local previewer = nil
	if config.preview.enabled then
		previewer = previewers.new_buffer_previewer({
			title = "Bookmark Preview",
			define_preview = function(self, entry)
				local bookmark = entry.value

				-- Try to read the file
				local file_lines = {}
				if vim.fn.filereadable(bookmark.filepath) then
					file_lines = vim.fn.readfile(bookmark.filepath)
				end

				if #file_lines == 0 then
					vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, { "File not found or empty" })
					return
				end

				-- Get context around the bookmark
				local start_line = math.max(1, bookmark.line_num - config.preview.context_lines)
				local end_line = math.min(#file_lines, bookmark.line_num + config.preview.context_lines)

				local preview_lines = {}

				-- Add bookmark info header
				table.insert(preview_lines, "📍 " .. bookmark.description)
				table.insert(preview_lines, "📁 " .. bookmark.filepath)
				table.insert(
					preview_lines,
					"🏷️  " .. (bookmark.category ~= "" and bookmark.category or "No category")
				)
				table.insert(preview_lines, "⏰ " .. os.date("%Y-%m-%d %H:%M:%S", bookmark.created_at))
				table.insert(preview_lines, "")

				-- Add file content with line numbers
				for i = start_line, end_line do
					local line = file_lines[i] or ""
					local prefix = i == bookmark.line_num and ">>> " or "    "
					table.insert(preview_lines, string.format("%s%d: %s", prefix, i, line))
				end

				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)

				-- Set syntax highlighting
				if config.preview.syntax_highlight and bookmark.filetype then
					vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "text")
				end
			end,
		})
	end

	pickers
		.new({}, {
			prompt_title = title,
			finder = finders.new_table({
				results = bookmarks,
				entry_maker = function(bookmark)
					return {
						value = bookmark,
						display = format_bookmark_entry(bookmark),
						ordinal = bookmark.description .. " " .. bookmark.filename .. " " .. bookmark.category,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = previewer,
			attach_mappings = function(prompt_bufnr, map)
				-- Default action - jump to bookmark
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						local bookmark = selection.value
						-- Open file and jump to bookmark
						vim.cmd("edit " .. vim.fn.fnameescape(bookmark.filepath))
						vim.api.nvim_win_set_cursor(0, { bookmark.line_num, bookmark.column })
						vim.notify("Jumped to bookmark: " .. bookmark.description, vim.log.levels.INFO)
					end
				end)

				-- Open in split
				map("i", "<C-s>", function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						local bookmark = selection.value
						vim.cmd("split " .. vim.fn.fnameescape(bookmark.filepath))
						vim.api.nvim_win_set_cursor(0, { bookmark.line_num, bookmark.column })
					end
				end)

				-- Open in vsplit
				map("i", "<C-v>", function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						local bookmark = selection.value
						vim.cmd("vsplit " .. vim.fn.fnameescape(bookmark.filepath))
						vim.api.nvim_win_set_cursor(0, { bookmark.line_num, bookmark.column })
					end
				end)

				-- Delete bookmark
				map("i", "<C-d>", function()
					local selection = action_state.get_selected_entry()
					if selection then
						local bookmark = selection.value
						M.delete_bookmark(bookmark.id)
						actions.close(prompt_bufnr)
						vim.defer_fn(function()
							M.show_telescope_bookmarks(
								M.get_bookmarks(
									title:lower():match("project") and "project"
										or title:lower():match("session") and "session"
										or "global"
								),
								title
							)
						end, 100)
					end
				end)

				-- Edit bookmark
				map("i", "<C-e>", function()
					local selection = action_state.get_selected_entry()
					if selection then
						M.edit_bookmark(selection.value)
						actions.close(prompt_bufnr)
					end
				end)

				return true
			end,
		})
		:find()
end

function M.show_bookmarks()
	local bookmarks = M.get_bookmarks()
	M.show_telescope_bookmarks(bookmarks, "All Bookmarks")
end

function M.show_project_bookmarks()
	local bookmarks = M.get_bookmarks("project")
	local project_name = state.current_project and vim.fn.fnamemodify(state.current_project, ":t") or "Unknown"
	M.show_telescope_bookmarks(bookmarks, "Project Bookmarks (" .. project_name .. ")")
end

function M.show_session_bookmarks()
	local bookmarks = M.get_bookmarks("session")
	M.show_telescope_bookmarks(bookmarks, "Session Bookmarks")
end

function M.show_global_bookmarks()
	local bookmarks = M.get_bookmarks("global")
	M.show_telescope_bookmarks(bookmarks, "Global Bookmarks")
end

function M.delete_bookmark(bookmark_id)
	for i, bookmark in ipairs(state.bookmarks) do
		if bookmark.id == bookmark_id then
			local desc = bookmark.description
			table.remove(state.bookmarks, i)
			save_bookmarks()
			vim.notify("Deleted bookmark: " .. desc, vim.log.levels.INFO)
			return
		end
	end
end

function M.edit_bookmark(bookmark)
	local new_description = vim.fn.input("Edit description: ", bookmark.description)
	if new_description == "" then
		return
	end

	local new_category = vim.fn.input("Edit category: ", bookmark.category)

	-- Update bookmark
	for _, b in ipairs(state.bookmarks) do
		if b.id == bookmark.id then
			b.description = new_description
			b.category = new_category
			save_bookmarks()
			vim.notify("Updated bookmark: " .. new_description, vim.log.levels.INFO)
			break
		end
	end
end

function M.clear_bookmarks(filter_type)
	local count = 0

	for i = #state.bookmarks, 1, -1 do
		local bookmark = state.bookmarks[i]
		local should_remove = false

		if filter_type == "project" and config.project_based then
			should_remove = bookmark.project_root == state.current_project
		elseif filter_type == "session" and config.session_based then
			should_remove = bookmark.session_id == state.current_session
		elseif filter_type == "all" then
			should_remove = true
		end

		if should_remove then
			table.remove(state.bookmarks, i)
			count = count + 1
		end
	end

	save_bookmarks()
	vim.notify("Cleared " .. count .. " bookmarks", vim.log.levels.INFO)
end

function M.get_stats()
	load_bookmarks()

	local stats = {
		total = #state.bookmarks,
		project = #M.get_bookmarks("project"),
		session = #M.get_bookmarks("session"),
		categories = {},
		filetypes = {},
	}

	for _, bookmark in ipairs(state.bookmarks) do
		stats.categories[bookmark.category] = (stats.categories[bookmark.category] or 0) + 1
		stats.filetypes[bookmark.filetype] = (stats.filetypes[bookmark.filetype] or 0) + 1
	end

	return stats
end

-- Commands
vim.api.nvim_create_user_command("BookmarkAdd", function(opts)
	M.add_bookmark(opts.args)
end, { desc = "Add bookmark", nargs = "?" })

vim.api.nvim_create_user_command("BookmarkList", M.show_bookmarks, { desc = "Show all bookmarks" })
vim.api.nvim_create_user_command("BookmarkProject", M.show_project_bookmarks, { desc = "Show project bookmarks" })
vim.api.nvim_create_user_command("BookmarkSession", M.show_session_bookmarks, { desc = "Show session bookmarks" })
vim.api.nvim_create_user_command("BookmarkGlobal", M.show_global_bookmarks, { desc = "Show global bookmarks" })
vim.api.nvim_create_user_command("BookmarkDelete", M.delete_bookmark_at_cursor, { desc = "Delete bookmark at cursor" })

vim.api.nvim_create_user_command("BookmarkClear", function(opts)
	local filter = opts.args ~= "" and opts.args or "all"
	M.clear_bookmarks(filter)
end, {
	desc = "Clear bookmarks",
	nargs = "?",
	complete = function()
		return { "all", "project", "session" }
	end,
})

vim.api.nvim_create_user_command("BookmarkStats", function()
	print(vim.inspect(M.get_stats()))
end, { desc = "Show bookmark statistics" })

return M
