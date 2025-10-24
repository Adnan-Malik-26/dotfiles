-- Autocommands Configuration
local api = vim.api
local augroup = api.nvim_create_augroup("UserConfig", { clear = true })

-- Highlight yanked text
vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#94e2d5", fg = "#000000" })
api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight text when yanking",
	group = augroup,
	callback = function()
		vim.highlight.on_yank({
			higroup = "YankHighlight",
			timeout = 200,
		})
	end,
})

-- Enhanced markdown support
api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	group = augroup,
	callback = function()
		local bufnr = api.nvim_get_current_buf()
		require("vim.treesitter").start(bufnr, "markdown")
	end,
})

-- Automatically reload files changed outside Neovim
api.nvim_create_autocmd("FocusGained", {
	group = augroup,
	command = "checktime",
})

-- Remember cursor position
api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	callback = function()
		local row, col = unpack(api.nvim_buf_get_mark(0, '"'))
		if row > 0 and row <= api.nvim_buf_line_count(0) then
			api.nvim_win_set_cursor(0, { row, col })
		end
	end,
})

-- Terminal configurations
api.nvim_create_autocmd("TermOpen", {
	group = augroup,
	callback = function()
		vim.opt.number = false
		vim.opt.relativenumber = false
		vim.cmd("startinsert")
	end,
})

-- Quick quit for certain file types
api.nvim_create_autocmd("FileType", {
	pattern = {
		"help",
		"qf",
		"lspinfo",
		"checkhealth",
		"fugitive",
		"git",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"netrw",
		"oil",
	},
	group = augroup,
	callback = function(event)
		vim.keymap.set("n", "q", "<cmd>close<cr>", {
			buffer = event.buf,
			silent = true,
		})
	end,
})

-- Floating window utilities
local function create_centered_float(bufnr)
	local width = math.floor(vim.o.columns * 0.6)
	local height = math.floor(vim.o.lines * 0.6)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	local opts = {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	}

	api.nvim_open_win(bufnr, true, opts)
end

-- Float help and checkhealth windows
api.nvim_create_autocmd("FileType", {
	pattern = { "help", "checkhealth" },
	group = augroup,
	callback = function(event)
		local bufnr = event.buf
		vim.defer_fn(function()
			if api.nvim_buf_is_valid(bufnr) then
				vim.cmd("close")
				create_centered_float(bufnr)
				vim.keymap.set("n", "q", "<cmd>close<cr>", {
					buffer = bufnr,
					silent = true,
				})
			end
		end, 10)
	end,
})
