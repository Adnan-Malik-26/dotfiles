-- lua/plugins/edline/init.lua
local M = {}

-- Cache for expensive operations
local cache = {
	git_info = { data = "", last_update = 0, file = "" },
	current_function = { data = "", last_update = 0, bufnr = -1 },
}

-- Cache timeout in milliseconds
local CACHE_TIMEOUT = 2000

-- Map vim modes to readable names
local mode_map = {
	n = "NORMAL",
	no = "O-PENDING",
	v = "VISUAL",
	V = "V-LINE",
	[""] = "V-BLOCK",
	i = "INSERT",
	ic = "INSERT",
	R = "REPLACE",
	Rv = "V-REPLACE",
	c = "COMMAND",
	cv = "VIM-EX",
	ce = "EX",
	r = "PROMPT",
	rm = "MORE",
	["r?"] = "CONFIRM",
	["!"] = "SHELL",
	t = "TERMINAL",
}

-- Filetype to color mapping
local filetype_colors = {
	lua = "#519aba", -- blue
	python = "#ffbc03", -- yellow
	javascript = "#f7df1e", -- yellow
	typescript = "#3178c6", -- blue
	javascriptreact = "#61dafb", -- cyan
	typescriptreact = "#61dafb", -- cyan
	html = "#e34c26", -- red-orange
	css = "#1572b6", -- blue
	scss = "#cf649a", -- pink
	sass = "#cf649a", -- pink
	json = "#cbcb41", -- yellow-green
	yaml = "#cb171e", -- red
	toml = "#9c4221", -- brown
	markdown = "#083fa1", -- blue
	vim = "#019833", -- green
	sh = "#4eaa25", -- green
	bash = "#4eaa25", -- green
	zsh = "#4eaa25", -- green
	fish = "#4eaa25", -- green
	rust = "#ce422b", -- rust orange
	go = "#00add8", -- cyan
	c = "#555555", -- gray
	cpp = "#f34b7d", -- pink
	java = "#ed8b00", -- orange
	php = "#777bb4", -- purple
	ruby = "#cc342d", -- red
	elixir = "#6e4a7e", -- purple
	erlang = "#b83998", -- magenta
	haskell = "#5e5086", -- purple
	clojure = "#db5855", -- red
	swift = "#fa7343", -- orange
	kotlin = "#7f52ff", -- purple
	scala = "#dc322f", -- red
	r = "#198ce7", -- blue
	julia = "#9558b2", -- purple
	matlab = "#e16737", -- orange
	tex = "#3d6117", -- dark green
	dockerfile = "#384d54", -- dark gray
	nix = "#5277c3", -- blue
	xml = "#0060ac", -- blue
	sql = "#336791", -- blue
	graphql = "#e10098", -- pink
	vue = "#4fc08d", -- green
	svelte = "#ff3e00", -- red-orange
	prisma = "#2d3748", -- dark gray
	proto = "#4285f4", -- blue
	make = "#427819", -- green
	cmake = "#064f8c", -- blue
}

-- Get current mode name
local function get_mode()
	local mode = vim.fn.mode()
	return mode_map[mode] or mode
end

-- Get current filename
local function get_filename()
	local filename = vim.fn.expand("%:t")
	if filename == "" then
		return "[No Name]"
	end
	return filename
end

-- Get git branch and status (cached)
local function get_git_info()
	local current_file = vim.fn.expand("%:p")
	local now = vim.loop.hrtime() / 1000000 -- Convert to milliseconds
	
	-- Check if cache is still valid
	if cache.git_info.file == current_file and 
	   (now - cache.git_info.last_update) < CACHE_TIMEOUT then
		return cache.git_info.data
	end
	
	-- Update cache
	local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
	if branch == "" or vim.v.shell_error ~= 0 then
		cache.git_info = { data = "", last_update = now, file = current_file }
		return ""
	end

	local result = ""
	-- Get git status for current file
	if current_file ~= "" then
		local status = vim.fn.system("git status --porcelain " .. vim.fn.shellescape(current_file) .. " 2>/dev/null")
		local indicator = ""
		if status ~= "" then
			local first_char = status:sub(1, 1)
			if first_char == "M" then
				indicator = " ●" -- modified
			elseif first_char == "A" then
				indicator = " +" -- added
			elseif first_char == "D" then
				indicator = " -" -- deleted
			elseif first_char == "?" then
				indicator = " ?" -- untracked
			else
				indicator = " ~" -- other changes
			end
		end
		result = string.format(" %s%s", branch, indicator)
	else
		result = string.format(" %s", branch)
	end
	
	cache.git_info = { data = result, last_update = now, file = current_file }
	return result
end

-- Get search count
local function get_search_count()
	if vim.v.hlsearch == 0 then
		return ""
	end

	local ok, result = pcall(vim.fn.searchcount, { maxcount = 99, timeout = 50 })
	if not ok or not result or result.total == 0 then
		return ""
	end

	if result.incomplete == 1 then
		return " [?/?]"
	elseif result.incomplete == 2 then
		return string.format(" [%d/>%d]", result.current, result.maxcount)
	else
		return string.format(" [%d/%d]", result.current, result.total)
	end
end

-- Get selection count in visual mode
local function get_selection_count()
	local mode = vim.fn.mode()
	if not (mode == "v" or mode == "V" or mode == "") then
		return ""
	end

	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")

	if mode == "v" then
		-- Character-wise selection
		local start_line, start_col = start_pos[2], start_pos[3]
		local end_line, end_col = end_pos[2], end_pos[3]

		if start_line == end_line then
			local chars = math.abs(end_col - start_col) + 1
			return string.format(" %dc", chars)
		else
			local lines = math.abs(end_line - start_line) + 1
			return string.format(" %dl", lines)
		end
	elseif mode == "V" then
		-- Line-wise selection
		local lines = math.abs(end_pos[2] - start_pos[2]) + 1
		return string.format(" %dl", lines)
	elseif mode == "" then
		-- Block-wise selection
		local lines = math.abs(end_pos[2] - start_pos[2]) + 1
		local cols = math.abs(end_pos[3] - start_pos[3]) + 1
		return string.format(" %dx%d", lines, cols)
	end

	return ""
end

-- Get current function using treesitter (cached)
local function get_current_function()
	local bufnr = vim.api.nvim_get_current_buf()
	local now = vim.loop.hrtime() / 1000000
	
	-- Check cache
	if cache.current_function.bufnr == bufnr and 
	   (now - cache.current_function.last_update) < CACHE_TIMEOUT then
		return cache.current_function.data
	end
	
	local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
	if not ok then
		cache.current_function = { data = "", last_update = now, bufnr = bufnr }
		return ""
	end

	local current_node = ts_utils.get_node_at_cursor()
	if not current_node then
		cache.current_function = { data = "", last_update = now, bufnr = bufnr }
		return ""
	end

	local function_node = current_node
	local result = ""
	
	while function_node do
		local node_type = function_node:type()
		-- Common function node types across languages
		if node_type:match("function") or 
		   node_type:match("method") or 
		   node_type:match("procedure") or
		   node_type == "function_definition" or
		   node_type == "function_declaration" or
		   node_type == "method_definition" or
		   node_type == "function_item" then
			-- Try to get function name
			for child in function_node:iter_children() do
				local child_type = child:type()
				if child_type == "identifier" or child_type == "name" then
					local name = vim.treesitter.get_node_text(child, 0)
					if name and name ~= "" then
						result = string.format(" %s()", name)
						break
					end
				end
			end
			if result ~= "" then break end
		end
		function_node = function_node:parent()
	end
	
	cache.current_function = { data = result, last_update = now, bufnr = bufnr }
	return result
end

-- Get modified indicator
local function get_modified_indicator()
	if vim.bo.modified then
		return " ●"
	elseif vim.bo.readonly then
		return " "
	else
		return ""
	end
end

-- Get filetype with colored icon
local function get_filetype()
	local ft = vim.bo.filetype
	if ft == "" then
		return "no ft"
	end

	local ok, devicons = pcall(require, "nvim-web-devicons")
	if ok then
		local icon = devicons.get_icon_by_filetype(ft, { default = true })
		if icon then
			-- Get color for this filetype
			local color = filetype_colors[ft] or "#cdd6f4" -- default to light text
			-- Create unique highlight group name
			local hl_group = "StatuslineIcon" .. ft:gsub("[^%w]", "")
			-- Set the highlight with the specific color
			vim.api.nvim_set_hl(0, hl_group, { fg = color, bg = "NONE" })
			return string.format("%%#%s#%s%%#StatuslineFT# %s", hl_group, icon, ft)
		end
	end
	return ft
end

-- Catppuccin Mocha colors
local colors = {
	dark_text = "#1e1e2e", -- dark text
	light_text = "#cdd6f4", -- light text
	normal = "#a6e3a1", -- green
	insert = "#89b4fa", -- blue
	visual = "#f5c2e7", -- pink
	replace = "#f38ba8", -- red
	command = "#f9e2af", -- yellow
	inactive = "#6c7086", -- gray
	accent = "#fab387", -- peach
	git = "#94e2d5", -- teal
	warning = "#f9e2af", -- yellow
	bg = "NONE", -- transparent
}

-- Pick color for current mode
local function mode_color()
	local m = vim.fn.mode()
	if m:find("n") then
		return colors.normal
	end
	if m:find("i") then
		return colors.insert
	end
	if m:find("R") then
		return colors.replace
	end
	if m:find("v") or m:find("V") or m:find("") then
		return colors.visual
	end
	if m:find("c") then
		return colors.command
	end
	return colors.inactive
end

-- Build statusline
function M.statusline()
	local hl_mode = "%#StatuslineMode#"
	local hl_file = "%#StatuslineFile#"
	local hl_git = "%#StatuslineGit#"
	local hl_search = "%#StatuslineSearch#"
	local hl_selection = "%#StatuslineSelection#"
	local hl_function = "%#StatuslineFunction#"
	local hl_modified = "%#StatuslineModified#"

	-- Left side components
	local mode = string.format("%s %s ", hl_mode, get_mode())
	local filename = string.format("%s %s", hl_file, get_filename())
	local git_info = get_git_info()
	local git = git_info ~= "" and string.format("%s%s", hl_git, git_info) or ""
	local search = get_search_count()
	local search_part = search ~= "" and string.format("%s%s", hl_search, search) or ""
	local selection = get_selection_count()
	local selection_part = selection ~= "" and string.format("%s%s", hl_selection, selection) or ""
	local current_func = get_current_function()
	local func_part = current_func ~= "" and string.format("%s%s", hl_function, current_func) or ""

	-- Right side components
	local modified = string.format("%s%s ", hl_modified, get_modified_indicator())
	local filetype = string.format(" %s ", get_filetype())

	local left = table.concat({
		mode,
		filename,
		git,
		search_part,
		selection_part,
		func_part,
	})

	local right = table.concat({
		modified,
		filetype,
	})

	return table.concat({
		left,
		"%=",
		right,
	})
end

-- Clear cache when switching buffers
local function clear_cache()
	cache.git_info = { data = "", last_update = 0, file = "" }
	cache.current_function = { data = "", last_update = 0, bufnr = -1 }
end

-- Setup highlights
function M.setup()
	-- Static highlight groups
	vim.api.nvim_set_hl(0, "StatuslineFile", { fg = colors.light_text, bg = colors.bg })
	vim.api.nvim_set_hl(0, "StatuslineFT", { fg = colors.light_text, bg = colors.bg })
	vim.api.nvim_set_hl(0, "StatuslineGit", { fg = colors.git, bg = colors.bg })
	vim.api.nvim_set_hl(0, "StatuslineSearch", { fg = colors.warning, bg = colors.bg })
	vim.api.nvim_set_hl(0, "StatuslineSelection", { fg = colors.visual, bg = colors.bg })
	vim.api.nvim_set_hl(0, "StatuslineFunction", { fg = colors.accent, bg = colors.bg })
	vim.api.nvim_set_hl(0, "StatuslineModified", { fg = colors.warning, bg = colors.bg })

	-- Dynamic mode highlight
	local function update_mode_hl()
		vim.api.nvim_set_hl(0, "StatuslineMode", { fg = colors.dark_text, bg = mode_color(), bold = true })
	end
	update_mode_hl()

	vim.o.statusline = "%!v:lua.require'plugins.edline'.statusline()"

	-- Reduced autocommands for better performance
	vim.api.nvim_create_autocmd({ 
		"ModeChanged", 
		"WinEnter", 
		"BufEnter",
		"BufWritePost" -- Update git status after save
	}, {
		callback = function()
			update_mode_hl()
			-- Only clear cache on buffer changes
			if vim.v.event.event == "BufEnter" then
				clear_cache()
			end
		end,
	})
	
	-- Separate group for search updates (less frequent)
	vim.api.nvim_create_autocmd({ 
		"CmdlineLeave",
		"SearchWrapped" 
	}, {
		callback = function()
			vim.cmd("redrawstatus")
		end,
	})
end

return M
