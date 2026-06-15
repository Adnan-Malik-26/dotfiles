require("snacks").setup({
	picker = {
		enabled = true,
	},
	terminal = {
		enabled = true,
	},
})

vim.keymap.set("n", "<leader>ff", function()
	Snacks.picker.files()
end)
vim.keymap.set("n", "<leader>bf", function()
	Snacks.picker.buffers()
end)
vim.keymap.set("n", "<leader>sf", function()
	Snacks.picker.smart()
end)
vim.keymap.set("n", "<leader>sh", function()
	Snacks.picker.help()
end)
vim.keymap.set("n", "<leader>rg", function()
	Snacks.picker.grep()
end)

vim.keymap.set("n", "<leader>tt", function()
	Snacks.terminal.open()
end)

vim.keymap.set("n", "<leader>tf", function()
	Snacks.terminal.focus()
end)
