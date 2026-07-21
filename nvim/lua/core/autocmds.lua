-- Autocommands Configuration
local api = vim.api
local augroup = api.nvim_create_augroup("UserConfig", { clear = true })

-- Highlight yanked text
vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#fefefe", fg = "#000000" })
api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight text when yanking",
	group = augroup,
	callback = function()
		vim.hl.hl_op({
      event = vim.v.event,
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

-- Obsidian + Telescope: only load when opening a markdown file inside your vault
-- vim.api.nvim_create_autocmd("BufReadPre", {
-- 	pattern = vim.fn.expand("~/Notes") .. "/*.md",
-- 	once = true,
-- 	callback = function()
-- 		vim.pack.add({
-- 			{ src = "https://github.com/nvim-telescope/telescope.nvim" },
-- 			{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
-- 			{ src = "https://github.com/epwalsh/obsidian.nvim" },
-- 		})
-- 		require("plugins.obsidian")
-- 	end,
-- })

-- checkmate: any markdown file, not just vault
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	once = true,
	callback = function()
		vim.pack.add({ { src = "https://github.com/bngarren/checkmate.nvim" } })
		require("plugins.markdown")
	end,
})

-- rustaceanvim: only .rs files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "rust",
	once = true,
	callback = function()
		vim.pack.add({ { src = "https://github.com/mrcjkb/rustaceanvim" } })
	end,
})

-- typst-preview: only .typ files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "typst",
	once = true,
	callback = function()
		vim.pack.add({ { src = "https://github.com/chomosuke/typst-preview.nvim" } })
	end,
})

-- rainbow-delimiters: first buffer with actual content, not startup
vim.api.nvim_create_autocmd("BufReadPost", {
	once = true,
	callback = function()
		vim.pack.add({ { src = "https://github.com/HiPhish/rainbow-delimiters.nvim" } })
	end,
})

-- notify: defer to first notification-worthy event
vim.api.nvim_create_autocmd("UIEnter", {
	once = true,
	callback = function()
		vim.defer_fn(function()
			vim.pack.add({ { src = "https://github.com/rcarriga/nvim-notify" } })
		end, 100)
	end,
})
