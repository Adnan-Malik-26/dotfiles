-- refiles.lua
-- Enhanced recent files plugin with project filtering and telescope integration

local M = {}

-- Configuration
local config = {
	max_recent_files = 100,
	keymap = "<leader>r",
	keymap_project = "<leader>rp",
	keymap_global = "<leader>rg",
	project_based = true,
	ignore_patterns = {
		"%.git/",
		"node_modules/",
		"%.pyc$",
		"%.o$",
		"%.class$",
		"/tmp/",
		"%.tmp$",
		"%.log$",
	},
	file_icons = {
		lua = "🌙",
		py = "🐍",
		js = "📜",
		ts = "🔷",
		html = "🌐",
		css = "🎨",
		json = "📋",
		md = "📝",
		txt = "📄",
		vim = "💚",
		sh = "🐚",
		rs = "🦀",
		go = "🐹",
		c = "⚙️",
		cpp = "⚙️",
		java = "☕",
		default = "📁",
	},
	show_modified_indicator = true,
	show_git_status = true,
	auto_cleanup = true,
}

-- Storage
local recent_files = {}
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

local function should_ignore_file(filepath)
	for _, pattern in ipairs(config.ignore_patterns) do
		if filepath:match(pattern) then
			return true
		end
	end
	return false
end

local function get_file_icon(filepath)
	local ext = filepath:match("%.([^%.]+)$")
	if not ext then
		return config.file_icons.default
	end
	return config.file_icons[ext:lower()] or config.file_icons.default
end

local function get_git_status(filepath)
	if not config.show_git_status then
		return ""
	end

	local cmd = "git -C "
		.. vim.fn.shellescape(vim.fn.fnamemodify(filepath, ":h"))
		.. " status --porcelain "
		.. vim.fn.shellescape(vim.fn.fnamemodify(filepath, ":t"))
		.. " 2>/dev/null"
	local result = vim.fn.system(cmd)

	if vim.v.shell_error ~= 0 or result == "" then
		return ""
	end

	local status = result:sub(1, 2)
	if status:match("M") then
		return " [Modified]"
	elseif status:match("A") then
		return " [Added]"
	elseif status:match("D") then
		return " [Deleted]"
	elseif status:match("R") then
		return " [Renamed]"
	elseif status:match("%?") then
		return " [Untracked]"
	end

	return ""
end

local function is_file_modified(filepath)
	if not config.show_modified_indicator then
		return false
	end

	-- Check if file is currently open in a buffer and modified
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			local buf_name = vim.api.nvim_buf_get_name(bufnr)
			if buf_name == filepath and vim.api.nvim_buf_get_option(bufnr, "modified") then
				return true
			end
		end
	end
	return false
end

local function format_relative_time(timestamp)
	local now = os.time()
	local diff = now - timestamp

	if diff < 60 then
		return "now"
	elseif diff < 3600 then
		return math.floor(diff / 60) .. "m"
	elseif diff < 86400 then
		return math.floor(diff / 3600) .. "h"
	elseif diff < 604800 then
		return math.floor(diff / 86400) .. "d"
	else
		return os.date("%m/%d", timestamp)
	end
end

local function cleanup_nonexistent_files()
	if not config.auto_cleanup then
		return
	end

	for i = #recent_files, 1, -1 do
		if not vim.fn.filereadable(recent_files[i].filepath) then
			table.remove(recent_files, i)
		end
	end
end

-- Main plugin functions
function M.setup(opts)
	opts = opts or {}
	config = vim.tbl_deep_extend("force", config, opts)

	current_project_root = config.project_based and get_project_root() or nil

	-- Track file opens
	vim.api.nvim_create_augroup("RecentFilesEnhanced", { clear = true })

	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		group = "RecentFilesEnhanced",
		callback = function()
			local filepath = vim.fn.expand("%:p")
			if filepath ~= "" then
				M.add_recent_file(filepath)
			end
		end,
	})

	-- Project change detection
	if config.project_based then
		vim.api.nvim_create_autocmd({ "DirChanged", "VimEnter" }, {
			group = "RecentFilesEnhanced",
			callback = function()
				current_project_root = get_project_root()
			end,
		})
	end

	-- Cleanup timer
	if config.auto_cleanup then
		vim.defer_fn(function()
			cleanup_nonexistent_files()
		end, 30000) -- Every 30 seconds
	end

	-- Set up keymaps
	vim.keymap.set("n", config.keymap, M.show_recent_files, { desc = "Show recent files" })
	vim.keymap.set("n", config.keymap_project, M.show_project_files, { desc = "Show recent project files" })
	vim.keymap.set("n", config.keymap_global, M.show_global_files, { desc = "Show all recent files" })
end

function M.add_recent_file(filepath)
	-- Skip if should be ignored
	if should_ignore_file(filepath) then
		return
	end

	-- Remove if already exists
	for i, entry in ipairs(recent_files) do
		if entry.filepath == filepath then
			table.remove(recent_files, i)
			break
		end
	end

	-- Add to front
	local entry = {
		filepath = filepath,
		filename = vim.fn.fnamemodify(filepath, ":t"),
		directory = vim.fn.fnamemodify(filepath, ":h"),
		project_root = current_project_root,
		timestamp = os.time(),
		filetype = vim.filetype.match({ filename = filepath }) or "text",
	}

	table.insert(recent_files, 1, entry)

	-- Limit size
	if #recent_files > config.max_recent_files then
		recent_files[config.max_recent_files + 1] = nil
	end
end

function M.get_recent_files(project_only)
	local files = {}

	for _, entry in ipairs(recent_files) do
		if not project_only or entry.project_root == current_project_root then
			table.insert(files, entry)
		end
	end

	return files
end

function M.show_recent_files()
	M.show_telescope_picker(M.get_recent_files(config.project_based), "Recent Files")
end

function M.show_project_files()
	M.show_telescope_picker(M.get_recent_files(true), "Project Recent Files")
end

function M.show_global_files()
	M.show_telescope_picker(M.get_recent_files(false), "All Recent Files")
end

local function format_entry(entry)
	local icon = get_file_icon(entry.filepath)
	local filename = entry.filename
	local time_str = format_relative_time(entry.timestamp)
	local git_status = get_git_status(entry.filepath)
	local modified_indicator = is_file_modified(entry.filepath) and " ●" or ""

	-- Show relative path from project root or home
	local display_path = entry.filepath
	if current_project_root and entry.filepath:find(current_project_root, 1, true) then
		display_path = entry.filepath:sub(#current_project_root + 2)
	else
		local home = vim.fn.expand("~")
		if entry.filepath:find(home, 1, true) then
			display_path = "~" .. entry.filepath:sub(#home + 1)
		end
	end

	return string.format(
		"%s %s%s%s (%s)%s",
		icon,
		filename,
		modified_indicator,
		git_status,
		time_str,
		#display_path > #filename + 10 and " - " .. vim.fn.fnamemodify(display_path, ":h") or ""
	)
end

function M.show_telescope_picker(files, title)
	local has_telescope, telescope = pcall(require, "telescope")
	if not has_telescope then
		vim.notify("Telescope is required for recent files", vim.log.levels.ERROR)
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")

	-- Cleanup before showing
	cleanup_nonexistent_files()

	if #files == 0 then
		vim.notify("No recent files found", vim.log.levels.INFO)
		return
	end

	-- File previewer
	local previewer = previewers.vim_buffer_cat.new({
		title = "File Preview",
		get_buffer_by_name = function(_, entry)
			return entry.value.filepath
		end,
	})

	pickers
		.new({}, {
			prompt_title = title
				.. (current_project_root and " (" .. vim.fn.fnamemodify(current_project_root, ":t") .. ")" or ""),
			finder = finders.new_table({
				results = files,
				entry_maker = function(entry)
					return {
						value = entry,
						display = format_entry(entry),
						ordinal = entry.filename .. " " .. entry.filepath,
						path = entry.filepath,
					}
				end,
			}),
			sorter = conf.file_sorter({}),
			previewer = previewer,
			attach_mappings = function(prompt_bufnr, map)
				-- Default action - open file
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						vim.cmd("edit " .. vim.fn.fnameescape(selection.value.filepath))
					end
				end)

				-- Open in split
				map("i", "<C-s>", function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						vim.cmd("split " .. vim.fn.fnameescape(selection.value.filepath))
					end
				end)

				-- Open in vsplit
				map("i", "<C-v>", function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						vim.cmd("vsplit " .. vim.fn.fnameescape(selection.value.filepath))
					end
				end)

				-- Open in new tab
				map("i", "<C-t>", function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						vim.cmd("tabedit " .. vim.fn.fnameescape(selection.value.filepath))
					end
				end)

				-- Remove from recent files
				map("i", "<C-d>", function()
					local selection = action_state.get_selected_entry()
					if selection then
						M.remove_recent_file(selection.value.filepath)
						actions.close(prompt_bufnr)
						vim.notify("Removed from recent files", vim.log.levels.INFO)
						-- Reopen with updated list
						vim.defer_fn(function()
							M.show_telescope_picker(M.get_recent_files(title:find("Project") ~= nil), title)
						end, 100)
					end
				end)

				-- Show file info
				map("i", "<C-i>", function()
					local selection = action_state.get_selected_entry()
					if selection then
						local entry = selection.value
						local info = {
							"File: " .. entry.filepath,
							"Size: " .. vim.fn.getfsize(entry.filepath) .. " bytes",
							"Modified: " .. os.date("%Y-%m-%d %H:%M:%S", vim.fn.getftime(entry.filepath)),
							"Accessed: " .. os.date("%Y-%m-%d %H:%M:%S", entry.timestamp),
							"Filetype: " .. entry.filetype,
							"Project: " .. (entry.project_root or "None"),
						}
						vim.notify(table.concat(info, "\n"), vim.log.levels.INFO)
					end
				end)

				return true
			end,
		})
		:find()
end

function M.remove_recent_file(filepath)
	for i, entry in ipairs(recent_files) do
		if entry.filepath == filepath then
			table.remove(recent_files, i)
			break
		end
	end
end

function M.clear_recent_files()
	recent_files = {}
end

function M.get_stats()
	local stats = {
		total_files = #recent_files,
		project_files = #M.get_recent_files(true),
		current_project = current_project_root,
		oldest_entry = recent_files[#recent_files]
				and os.date("%Y-%m-%d %H:%M:%S", recent_files[#recent_files].timestamp)
			or "None",
		newest_entry = recent_files[1] and os.date("%Y-%m-%d %H:%M:%S", recent_files[1].timestamp) or "None",
	}
	return stats
end

-- Commands
vim.api.nvim_create_user_command("RecentFiles", M.show_recent_files, { desc = "Show recent files" })
vim.api.nvim_create_user_command("RecentFilesProject", M.show_project_files, { desc = "Show recent project files" })
vim.api.nvim_create_user_command("RecentFilesGlobal", M.show_global_files, { desc = "Show all recent files" })
vim.api.nvim_create_user_command("RecentFilesClear", M.clear_recent_files, { desc = "Clear recent files" })
vim.api.nvim_create_user_command("RecentFilesStats", function()
	print(vim.inspect(M.get_stats()))
end, { desc = "Show recent files statistics" })

return M
