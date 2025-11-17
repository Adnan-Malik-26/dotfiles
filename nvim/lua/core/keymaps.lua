-- Key Mappings Configuration
local map = vim.keymap.set
local keymap_sets = { noremap = true, silent = true }
local function desc(description)
	return vim.tbl_extend("force", keymap_sets, { desc = description })
end

-- General mappings
map("n", "+", "<C-a>", desc("Increment number"))
map("n", "-", "<C-x>", desc("Decrement number"))
map("n", "<C-a>", "gg<S-v>G", desc("Select all"))
map("n", "#", "$", desc("Go to end of line"))
map("n", ";", ":", { noremap = true, desc = "Enter command mode" })
map("v", ";", ":", { noremap = true, desc = "Enter command mode" })
map("n", "<ESC>", ":nohlsearch<CR>", desc("Clear search highlight"))
map("n", "n", "nzzzv", { noremap = true, desc = "Enter command mode" })
map("n", "N", "nzzzv", { noremap = true, desc = "Enter command mode" })
map("n", "<C-d>", "<C-d>zz", { noremap = true, desc = "Enter command mode" })
map("n", "<C-u>", "<C-u>zz", { noremap = true, desc = "Enter command mode" })

-- Config management
map("n", "<leader>o", ":update<CR> :source<CR>", desc("Write and source config"))

-- Line movement
map("n", "<A-S-j>", ":m .+1<CR>==", desc("Move line down"))
map("n", "<A-S-k>", ":m .-2<CR>==", desc("Move line up"))
map("v", "<A-S-j>", ":m '>+1<CR>gv=gv", desc("Move block down"))
map("v", "<A-S-k>", ":m '<-2<CR>gv=gv", desc("Move block up"))

-- Indentation
map("v", "<", "<gv", desc("Indent left and keep selection"))
map("v", ">", ">gv", desc("Indent right and keep selection"))

-- Clipboard operations
map({ "n", "v", "x" }, "<leader>y", '"+y<CR>', desc("Copy to system clipboard"))
map({ "n", "v", "x" }, "<leader>d", '"+d<CR>', desc("Delete and copy to system clipboard"))
map({ "n", "v", "x" }, "<leader>p", '"+p<CR>', desc("Paste from system clipboard"))

-- File explorer
map("n", "<leader>e", "<CMD>Oil<CR>", desc("Open File Explorer Oil"))

-- Window navigation (tmux)
map("n", "<C-h>", ":TmuxNavigateLeft<CR>", desc("Go to left window"))
map("n", "<C-j>", ":TmuxNavigateDown<CR>", desc("Go to down window"))
map("n", "<C-k>", ":TmuxNavigateUp<CR>", desc("Go to up window"))
map("n", "<C-l>", ":TmuxNavigateRight<CR>", desc("Go to right window"))

map("n", "<A-h>", "<C-w>h", desc("Go to left window"))
map("n", "<A-j>", "<C-w>j", desc("Go to down window"))
map("n", "<A-k>", "<C-w>k", desc("Go to up window"))
map("n", "<A-l>", "<C-w>l", desc("Go to right window"))

-- Buffer navigation
map("n", "<Tab>", "<CMD>BufferLineCycleNext<CR>", desc("Go to next buffer"))
map("n", "<S-Tab>", "<CMD>BufferLineCyclePrev<CR>", desc("Go to previous buffer"))
map("n", "<leader>q", "<CMD>bdelete!<CR>", desc("Delete current buffer"))
map("n", "<leader>bo", ":%bd|e#|bd#<CR>", desc("Close other buffers"))
map("n", "<leader><leader>", "<C-^>", desc("Switch to last buffer"))

-- Terminal
map("t", "<Esc>", [[<C-\><C-n>]], desc("Exit terminal mode"))

-- Window splits
map("n", "<leader>sh", "<CMD>split<CR> <CMD>Telescope find_files<CR>", desc("Split horizontally"))
map("n", "<leader>sv", "<CMD>vsplit<CR> <CMD>Telescope find_files<CR>", desc("Split vertically"))

-- Window resizing
map("n", "<C-A-h>", "<CMD>vertical resize +5<CR>", desc("Resize left"))
map("n", "<C-A-j>", "<CMD>resize +5<CR>", desc("Resize down"))
map("n", "<C-A-k>", "<CMD>resize -5<CR>", desc("Resize up"))
map("n", "<C-A-l>", "<CMD>vertical resize -5<CR>", desc("Resize right"))

-- Spelling
map("n", "<C-S-s>", "<cmd>set spell<CR>", desc("Enable Spelling"))
map("n", "<A-CR>", "1z=", desc("Correct Spelling under Cursor"))

-- Rupees
map("i", "<A-S-r>", "₹", desc("Enter Rupees"))

-- Open Todo
vim.keymap.set("n", "<leader>t", function()
	local todo_path = vim.fn.expand("~/Notes/TODO.md")
	local dir = vim.fn.fnamemodify(todo_path, ":h")
	vim.fn.mkdir(dir, "p")
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local col = math.floor((vim.o.columns - width) / 2)
	local row = math.floor((vim.o.lines - height) / 2)
	local buf = vim.api.nvim_create_buf(false, false)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
		border = "rounded",
	})

	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.cmd("edit " .. vim.fn.fnameescape(todo_path))
	vim.api.nvim_buf_set_option(buf, "filetype", "markdown")

	vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, noremap = true, silent = true })
	vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, noremap = true, silent = true })
end, { desc = "Open Todo in floating window" })
