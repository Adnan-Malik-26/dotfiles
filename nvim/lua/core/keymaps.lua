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
map("n", "<C-d>", "<C-d>zz", { noremap = true, desc = "Enter command mode" })
map("n", "<C-u>", "<C-u>zz", { noremap = true, desc = "Enter command mode" })

-- Config management
map("n", "<leader>o", ":update<CR> :source<CR>", desc("Write and source config"))

-- Enable inlay hints
map("n", "<leader>ih", function()
	vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })

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

-- Buffer navigation
map("n", "<Tab>", "<CMD>BufferLineCycleNext<CR>", desc("Go to next buffer"))
map("n", "<S-Tab>", "<CMD>BufferLineCyclePrev<CR>", desc("Go to previous buffer"))
map("n", "<leader>q", "<CMD>bdelete!<CR>", desc("Delete current buffer"))
map("n", "<leader>bo", ":%bd|e#|bd#<CR>", desc("Close other buffers"))
map("n", "<leader><leader>", "<C-^>", desc("Switch to last buffer"))

-- Spelling
map("n", "<A-CR>", "1z=", desc("Correct Spelling under Cursor"))

vim.keymap.set("n", "gK", function()
	local new_config = not vim.diagnostic.config().virtual_lines
	vim.diagnostic.config({ virtual_lines = new_config })
end, { desc = "Toggle diagnostic virtual_lines" })

-- Rename Current File
vim.keymap.set("n", "<leader>rn", function()
  local old = vim.api.nvim_buf_get_name(0)
  if old == "" then
    vim.notify("No file associated with buffer", vim.log.levels.ERROR)
    return
  end

  local new = vim.fn.input("Rename to: ", old, "file")
  if new == "" or new == old then
    return
  end

  local ok, err = vim.uv.fs_rename(old, new)
  if not ok then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_buf_set_name(0, new)
  vim.cmd("checktime")
  vim.notify("Renamed to " .. new)
end, { desc = "Rename current file" })

vim.keymap.set("n", "gl", vim.diagnostic.open_float)

-- Rupees
map("i", "<A-S-r>", "₹", desc("Enter Rupees"))
