---@type ChadrcConfig
local M = {}

M.ui = {
  theme = 'chocolate',
  transparency = true,


  statusline = {
    theme = "minimal",
    separator_style = "arrow",
  },

  nvdash = {
    load_on_startup = true,
  },
}
M.plugins = 'custom.plugins'
return M
