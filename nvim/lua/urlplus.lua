-- urlplus.lua
-- Extract and manage URLs in current buffer with Telescope integration

local M = {}

-- Configuration
local config = {
	keymap = "<leader>u",
	keymap_copy = "<leader>uc",
	keymap_open = "<leader>uo",
	patterns = {
		-- HTTP/HTTPS URLs
		"https?://[%w%-._~:/?#%[%]@!$&'()*+,;=]+",
		-- FTP URLs
		"ftp://[%w%-._~:/?#%[%]@!$&'()*+,;=]+",
		-- File URLs
		"file://[%w%-._~:/?#%[%]@!$&'()*+,;=]+",
		-- Git URLs (SSH)
		"git@[%w%.%-]+:[%w%-._/]+%.git",
		-- Simple domain patterns (www.example.com)
		"www%.[%w%-%.]+%.[%w]+[%w%-._~:/?#%[%]@!$&'()*+,;=]*",
	},
	ignore_patterns = {
		-- Common false positives
		"127%.0%.0%.1",
		"0%.0%.0%.0",
		"localhost",
		-- Version numbers that look like URLs
		"%d+%.%d+%.%d+",
	},
	icons = {
		http = "🌐",
		https = "🔒",
		ftp = "📁",
		file = "📄",
		git = "🔗",
		www = "🌍",
		unknown = "🔗",
	},
	show_line_numbers = true,
	show_preview = true,
	sort_by = "line", -- "line", "url", "type"
	validate_urls = false, -- Check if URL is reachable (experimental)
}

-- State
local state = {
	cached_urls = {},
	last_scan_time = 0,
}

-- Utility functions
local function get_url_type(url)
	if url:match("^https://") then
		return "https"
	elseif url:match("^http://") then
		return "http"
	elseif url:match("^ftp://") then
		return "ftp"
	elseif url:match("^file://") then
		return "file"
	elseif url:match("^git@") then
		return "git"
	elseif url:match("^www%.") then
		return "www"
	else
		return "unknown"
	end
end

local function get_icon(url_type)
	return config.icons[url_type] or config.icons.unknown
end

local function should_ignore_url(url)
	for _, pattern in ipairs(config.ignore_patterns) do
		if url:match(pattern) then
			return true
		end
	end
	return false
end

local function is_valid_url(url)
	-- Basic validation - check if it has valid structure
	if not url or url == "" then
		return false
	end

	-- Check length (reasonable URL length)
	if #url > 2048 then
		return false
	end

	-- Must not be just dots, numbers, or too short
	if #url < 4 or url:match("^[%.%d]+$") then
		return false
	end

	return true
end

local function extract_urls_from_buffer(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()

	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local urls = {}
	local seen_urls = {} -- Prevent duplicates

	for line_num, line_content in ipairs(lines) do
		-- Try each URL pattern
		for _, pattern in ipairs(config.patterns) do
			for url in line_content:gmatch(pattern) do
				-- Clean up the URL (remove trailing punctuation that might be caught)
				url = url:gsub("[%)%]}>.,;:!?]+$", "")

				-- Validate URL
				if is_valid_url(url) and not should_ignore_url(url) then
					-- Create unique key to avoid duplicates
					local url_key = url .. "_" .. line_num
					if not seen_urls[url_key] then
						seen_urls[url_key] = true

						-- Find exact position of URL in line
						local start_col, end_col = line_content:find(vim.pesc(url), 1, true)

						table.insert(urls, {
							url = url,
							line_num = line_num,
							line_content = line_content,
							start_col = start_col or 1,
							end_col = end_col or #url,
							url_type = get_url_type(url),
							timestamp = os.time(),
						})
					end
				end
			end
		end
	end

	-- Sort URLs
	if config.sort_by == "line" then
		table.sort(urls, function(a, b)
			return a.line_num < b.line_num
		end)
	elseif config.sort_by == "url" then
		table.sort(urls, function(a, b)
			return a.url < b.url
		end)
	elseif config.sort_by == "type" then
		table.sort(urls, function(a, b)
			if a.url_type == b.url_type then
				return a.line_num < b.line_num
			end
			return a.url_type < b.url_type
		end)
	end

	return urls
end

local function format_entry(entry)
	local icon = get_icon(entry.url_type)
	local line_info = config.show_line_numbers and string.format("[%d] ", entry.line_num) or ""
	local url_display = entry.url

	-- Truncate very long URLs for display
	if #url_display > 80 then
		url_display = url_display:sub(1, 77) .. "..."
	end

	return string.format("%s %s%s", icon, line_info, url_display)
end

local function copy_url_to_clipboard(url)
	vim.fn.setreg("+", url)
	vim.fn.setreg('"', url)
	vim.notify("Copied URL to clipboard: " .. url, vim.log.levels.INFO)
end

local function open_url_external(url)
	local cmd
	if vim.fn.has("mac") == 1 then
		cmd = "open"
	elseif vim.fn.has("unix") == 1 then
		cmd = "xdg-open"
	elseif vim.fn.has("win32") == 1 then
		cmd = "start"
	else
		vim.notify("Cannot determine how to open URLs on this system", vim.log.levels.ERROR)
		return
	end

	-- Add protocol if missing for www URLs
	local open_url = url
	if url:match("^www%.") then
		open_url = "https://" .. url
	end

	vim.fn.jobstart({ cmd, open_url }, {
		on_exit = function(_, exit_code)
			if exit_code == 0 then
				vim.notify("Opened URL: " .. url, vim.log.levels.INFO)
			else
				vim.notify("Failed to open URL: " .. url, vim.log.levels.ERROR)
			end
		end,
	})
end

-- Main plugin functions
function M.setup(opts)
	opts = opts or {}
	config = vim.tbl_deep_extend("force", config, opts)

	-- Set up keymaps
	vim.keymap.set("n", config.keymap, M.show_urls, { desc = "Extract URLs from buffer" })
	vim.keymap.set("n", config.keymap_copy, M.copy_all_urls, { desc = "Copy all URLs to clipboard" })
	vim.keymap.set("n", config.keymap_open, M.open_all_urls, { desc = "Open all URLs" })
end

function M.extract_urls(bufnr)
	return extract_urls_from_buffer(bufnr)
end

function M.show_urls(bufnr)
	local has_telescope, telescope = pcall(require, "telescope")
	if not has_telescope then
		vim.notify("Telescope is required for URL extractor", vim.log.levels.ERROR)
		return
	end

	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local urls = extract_urls_from_buffer(bufnr)

	if #urls == 0 then
		vim.notify("No URLs found in current buffer", vim.log.levels.INFO)
		return
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local previewers = require("telescope.previewers")

	-- Custom previewer to show line content and URL info
	local previewer = nil
	if config.show_preview then
		previewer = previewers.new_buffer_previewer({
			title = "URL Context",
			define_preview = function(self, entry)
				local url_entry = entry.value
				local preview_lines = {}

				-- Show URL details
				table.insert(preview_lines, "URL: " .. url_entry.url)
				table.insert(preview_lines, "Type: " .. url_entry.url_type)
				table.insert(preview_lines, "Line: " .. url_entry.line_num)
				table.insert(preview_lines, "Position: " .. url_entry.start_col .. "-" .. url_entry.end_col)
				table.insert(preview_lines, "")
				table.insert(preview_lines, "Context:")
				table.insert(preview_lines, "")

				-- Show surrounding lines for context
				local context_start = math.max(1, url_entry.line_num - 3)
				local context_end = math.min(vim.api.nvim_buf_line_count(bufnr), url_entry.line_num + 3)
				local context_lines = vim.api.nvim_buf_get_lines(bufnr, context_start - 1, context_end, false)

				for i, line in ipairs(context_lines) do
					local line_num = context_start + i - 1
					local prefix = line_num == url_entry.line_num and ">>> " or "    "
					table.insert(preview_lines, string.format("%s%d: %s", prefix, line_num, line))
				end

				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
			end,
		})
	end

	pickers
		.new({}, {
			prompt_title = string.format("URLs in Buffer (%d found)", #urls),
			finder = finders.new_table({
				results = urls,
				entry_maker = function(entry)
					return {
						value = entry,
						display = format_entry(entry),
						ordinal = entry.url .. " " .. entry.line_content,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = previewer,
			attach_mappings = function(prompt_bufnr, map)
				-- Default action - go to line
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						-- Jump to the line and position cursor on URL
						vim.api.nvim_win_set_cursor(0, { selection.value.line_num, selection.value.start_col - 1 })
						vim.notify("Jumped to URL at line " .. selection.value.line_num, vim.log.levels.INFO)
					end
				end)

				-- Copy URL to clipboard
				map("i", "<C-y>", function()
					local selection = action_state.get_selected_entry()
					if selection then
						copy_url_to_clipboard(selection.value.url)
					end
				end)

				-- Open URL in external browser
				map("i", "<C-o>", function()
					local selection = action_state.get_selected_entry()
					if selection then
						open_url_external(selection.value.url)
					end
				end)

				-- Copy all URLs
				map("i", "<C-a>", function()
					local all_urls = {}
					for _, url in ipairs(urls) do
						table.insert(all_urls, url.url)
					end
					local urls_text = table.concat(all_urls, "\n")
					vim.fn.setreg("+", urls_text)
					vim.fn.setreg('"', urls_text)
					vim.notify("Copied " .. #all_urls .. " URLs to clipboard", vim.log.levels.INFO)
				end)

				-- Show URL statistics
				map("i", "<C-i>", function()
					local stats = M.get_stats(urls)
					vim.notify(vim.inspect(stats), vim.log.levels.INFO)
				end)

				return true
			end,
		})
		:find()
end

function M.copy_all_urls(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local urls = extract_urls_from_buffer(bufnr)

	if #urls == 0 then
		vim.notify("No URLs found to copy", vim.log.levels.INFO)
		return
	end

	local url_list = {}
	for _, entry in ipairs(urls) do
		table.insert(url_list, entry.url)
	end

	local urls_text = table.concat(url_list, "\n")
	vim.fn.setreg("+", urls_text)
	vim.fn.setreg('"', urls_text)
	vim.notify("Copied " .. #urls .. " URLs to clipboard", vim.log.levels.INFO)
end

function M.open_all_urls(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local urls = extract_urls_from_buffer(bufnr)

	if #urls == 0 then
		vim.notify("No URLs found to open", vim.log.levels.INFO)
		return
	end

	if #urls > 10 then
		local choice = vim.fn.confirm("Found " .. #urls .. " URLs. Open all of them?", "&Yes\n&No\n&First 10 only", 2)
		if choice == 2 then
			return
		elseif choice == 3 then
			urls = { unpack(urls, 1, 10) }
		end
	end

	for _, entry in ipairs(urls) do
		open_url_external(entry.url)
		-- Small delay to not overwhelm the system
		vim.defer_fn(function() end, 100)
	end

	vim.notify("Opened " .. #urls .. " URLs", vim.log.levels.INFO)
end

function M.get_stats(urls)
	urls = urls or extract_urls_from_buffer()

	local stats = {
		total = #urls,
		by_type = {},
		unique_domains = {},
		longest_url = "",
		shortest_url = "",
	}

	local longest_len = 0
	local shortest_len = math.huge

	for _, entry in ipairs(urls) do
		-- Count by type
		stats.by_type[entry.url_type] = (stats.by_type[entry.url_type] or 0) + 1

		-- Track domains
		local domain = entry.url:match("://([^/]+)") or entry.url:match("^([^/]+)")
		if domain then
			stats.unique_domains[domain] = true
		end

		-- Track URL lengths
		if #entry.url > longest_len then
			longest_len = #entry.url
			stats.longest_url = entry.url
		end
		if #entry.url < shortest_len then
			shortest_len = #entry.url
			stats.shortest_url = entry.url
		end
	end

	stats.unique_domain_count = vim.tbl_count(stats.unique_domains)
	stats.unique_domains = nil -- Don't show full domain list

	return stats
end

-- Commands
vim.api.nvim_create_user_command("URLExtract", M.show_urls, { desc = "Extract URLs from current buffer" })
vim.api.nvim_create_user_command("URLCopy", M.copy_all_urls, { desc = "Copy all URLs to clipboard" })
vim.api.nvim_create_user_command("URLOpen", M.open_all_urls, { desc = "Open all URLs in browser" })
vim.api.nvim_create_user_command("URLStats", function()
	print(vim.inspect(M.get_stats()))
end, { desc = "Show URL statistics" })

return M
