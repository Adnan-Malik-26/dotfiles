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
		if vim.bo.filetype == "help" or vim.bo.buftype ~= "" then
			return
		end
		local mark = api.nvim_buf_get_mark(0, '"')
		local row, col = mark[1], mark[2]
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

vim.api.nvim_create_user_command("RestartNvim", function()
	vim.cmd("wall") -- save all
	local args = vim.v.argv
	vim.fn.jobstart(args, { detach = true })
	vim.cmd("qa!")
end, {})
