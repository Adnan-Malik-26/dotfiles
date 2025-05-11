require "nvchad.mappings"
-- add yours here
local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map("n", "<leader>tt", ":lua require('base46').toggle_transparency()<CR>", { noremap = true, silent = true, desc = "Toggle Background Transparency" })






map("n", "<leader>lw", function()
  local input = vim.fn.input("How many words? ")
  local count = tonumber(input) or 10
  local lorem = require("lorem").words(count)
  vim.api.nvim_put({ lorem }, "", true, true)
end, { noremap = true, silent = true, desc = "Insert Lorem Ipsum Words" })

-- Insert Lorem Ipsum Paragraphs
map("n", "<leader>lp", function()
  local input = vim.fn.input("How many paragraphs? ")
  local count = tonumber(input) or 1
  local lorem = require("lorem").paragraphs(count)
  vim.api.nvim_put({ lorem }, "", true, true)
end, { noremap = true, silent = true, desc = "Insert Lorem Ipsum Paragraphs" })

