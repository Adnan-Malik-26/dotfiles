local telescope = require("telescope")
-- Telescope Configuration
telescope.setup({
	extensions = {
		["ui-select"] = {
			require("telescope.themes").get_dropdown({}),
		},
	},
})

telescope.load_extension("ui-select")

-- maps
local builtin = require("telescope.builtin")
local map = vim.keymap.set

map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
map("n", "<leader>bf", builtin.buffers, { desc = "Find buffers" })
map("n", "<leader>rg", builtin.live_grep, { desc = "Live grep" })
map("n", "<leader>h", builtin.help_tags, { desc = "Help tags" })
map("n", "<leader>bb", builtin.builtin, { desc = "Telescope builtins" })
