-- Obsidian.nvim Configuration
require("obsidian").setup({
	workspaces = {
		{
			name = "notes",
			path = "~/Notes",
		},
	},

	notes_subdir = "inbox",
	new_notes_location = "notes_subdir",

	daily_notes = {
		folder = "daily",
		date_format = "%Y-%m-%d",
		alias_format = "%B %-d, %Y",
		default_tags = { "daily-note" },
		template = nil,
	},

	completion = {
		nvim_cmp = false,
		blink = true,
		min_chars = 2,
	},

  picker = {
    name = "telescope.nvim",
    note_mappings = {
      new = "<C-x>",
      insert_link = "<C-l>",
    },
    tag_mappings = {
      tag_note = "<C-x>",
      insert_tag = "<C-l>",
    },
  },

	ui = {
		enable = false,
		checkboxes = {
			[" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
			["x"] = { char = "󰱒", hl_group = "ObsidianDone" },
			[">"] = { char = "", hl_group = "ObsidianRightArrow" },
			["~"] = { char = "󰜥", hl_group = "ObsidianTilde" },
		},
	},

	wiki_link_func = "use_alias_only",
	preferred_link_style = "wiki",

	disable_frontmatter = false,

	templates = {
		subdir = "templates",
		date_format = "%Y-%m-%d",
		time_format = "%H:%M",
	},

	attachments = {
		img_folder = "assets/imgs",
	},

	footer = {
		enabled = true,
	},
})

--------------------------------------------------------------------------------
-- KEYMAPS
--------------------------------------------------------------------------------
local map = vim.keymap.set
local function desc(d)
	return { noremap = true, silent = true, desc = d }
end

map("n", "<leader>on", "<CMD>ObsidianNew<CR>", desc("Obsidian: New note"))
map("n", "<leader>oo", "<CMD>ObsidianQuickSwitch<CR>", desc("Obsidian: Quick switch"))
map("n", "<leader>os", "<CMD>ObsidianSearch<CR>", desc("Obsidian: Search vault"))
map("n", "<leader>od", "<CMD>ObsidianToday<CR>", desc("Obsidian: Today's daily note"))
map("n", "<leader>oy", "<CMD>ObsidianYesterday<CR>", desc("Obsidian: Yesterday's daily note"))
map("n", "<leader>ob", "<CMD>ObsidianBacklinks<CR>", desc("Obsidian: Show backlinks"))
map("n", "<leader>ol", "<CMD>ObsidianLinks<CR>", desc("Obsidian: Show links in note"))
map("n", "<leader>ot", "<CMD>ObsidianTags<CR>", desc("Obsidian: Search tags"))
map("n", "<leader>oT", "<CMD>ObsidianTemplate<CR>", desc("Obsidian: Insert template"))
map("n", "<leader>ow", "<CMD>ObsidianWorkspace<CR>", desc("Obsidian: Switch workspace"))
map("n", "<leader>op", "<CMD>ObsidianPasteImg<CR>", desc("Obsidian: Paste image"))
map("n", "<leader>oR", "<CMD>ObsidianRename<CR>", desc("Obsidian: Rename note (updates refs)"))
map("n", "<leader>oc", "<CMD>ObsidianCheck<CR>", desc("Obsidian: Check vault for issues"))
map("n", "<leader>oi", "<CMD>ObsidianTOC<CR>", desc("Obsidian: Table of contents"))

-- Follow link / toggle checkbox — filetype-scoped
vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function(event)
		vim.opt_local.conceallevel = 2

		map("n", "<CR>", "<CMD>ObsidianFollowLink<CR>", { buffer = event.buf, desc = "Obsidian: Follow link" })
		map("n", "<leader>ox", "<CMD>ObsidianToggleCheckbox<CR>", { buffer = event.buf, desc = "Obsidian: Toggle checkbox" })
		map("v", "<leader>oe", "<CMD>ObsidianExtractNote<CR>", { buffer = event.buf, desc = "Obsidian: Extract selection to new note" })
		map("v", "<leader>oL", "<CMD>ObsidianLink<CR>", { buffer = event.buf, desc = "Obsidian: Link selection to existing note" })
	end,
})
