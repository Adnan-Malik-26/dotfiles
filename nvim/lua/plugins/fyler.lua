local fyler = require("fyler")

fyler.setup({
	-- your config options here
	integrations = { icon = "nvim_web_devicons" },
	views = {
		finder = { close_on_select = true, git_status = { enabled = true } },
	},
})
