-- Entry Point
vim.g.mapleader = " "

-- Load core configurations
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Load plugin configurations
require("plugins.init")

-- Load custom features
require("features.marks")
-- require("features.obsidian")

-- Load custom colors
require("colors.colors")
