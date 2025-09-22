-- plugin/floatterm.lua

-- Prevent loading plugin twice
if vim.g.loaded_floatterm then
	return
end
vim.g.loaded_floatterm = true

local floatterm = require("floatterm")

-- Commands
vim.api.nvim_create_user_command("FloatTermToggle", function()
	floatterm.toggle()
end, { desc = "Toggle floating terminal" })

vim.api.nvim_create_user_command("FloatTermOpen", function()
	floatterm.open()
end, { desc = "Open floating terminal" })

vim.api.nvim_create_user_command("FloatTermClose", function()
	floatterm.close()
end, { desc = "Close floating terminal" })

vim.api.nvim_create_user_command("FloatTermNew", function(opts)
	local name = opts.args ~= "" and opts.args or nil
	floatterm.add_terminal(name)
end, { desc = "Create new terminal", nargs = "?" })

-- Global keymaps for terminal navigation
vim.keymap.set({ "n", "t" }, "<leader>ts", function()
	local floatterm = require("floatterm")
	-- Get current state
	local state = floatterm._get_state and floatterm._get_state()
	if state and state.is_open and state.sidebar_win and vim.api.nvim_win_is_valid(state.sidebar_win) then
		if vim.api.nvim_get_current_win() ~= state.sidebar_win then
			vim.cmd("stopinsert")
			vim.api.nvim_set_current_win(state.sidebar_win)
		end
	end
end, { desc = "Focus terminal sidebar", silent = true })

vim.keymap.set("n", "<leader>tn", function()
	require("floatterm").add_terminal()
end, { desc = "Add new terminal", silent = true })

-- Default keymaps (users can override these)
vim.keymap.set({ "n", "t" }, "<F12>", function()
	floatterm.toggle()
end, { desc = "Toggle FloatTerm", silent = true })

vim.keymap.set("t", "<C-\\><C-n>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Setup with default config (users can call setup() to override)
floatterm.setup()
