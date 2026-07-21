-- Entry Point
vim.g.mapleader = " "

-- Load plugin configurations
require("plugins.init")

-- Load core configurations
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.packadd")

-- Load custom features
require("features.marks")
-- require("features.statusline")

-- Load custom colors
require("colors.colors")
