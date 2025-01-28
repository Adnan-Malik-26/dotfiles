require 'core.options'  -- ./lua/core/options.lua
require 'core.keymaps'  -- ./lua/core/keymaps.lua
require 'core.snippets' -- ./lua/core/snippets.lua

-- Install package manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins
require('lazy').setup({
  require 'plugins.themes.gruvbox',
  require 'plugins.obsidian',
  require 'plugins.vimbegood',
  require 'plugins.telescope',
  require 'plugins.treesitter',
--  require 'plugins.lsp',
  require 'plugins.autocompletion',
--  require 'plugins.none-ls',
  require 'plugins.lualine',
--  require 'plugins.bufferline',
  require 'plugins.neo-tree',
  require 'plugins.alpha',
  require 'plugins.indent-blankline',
  require 'plugins.comment',
  require 'plugins.debug',
  require 'plugins.gitsigns',
  require 'plugins.database',
  require 'plugins.misc',
  require 'plugins.markdown',
  -- require 'plugins.lazygit',
  -- require 'plugins.harpoon',
  -- require 'plugins.neorg',
  -- require 'plugins.avante',
  -- require 'plugins.chatgpt',
  -- require 'plugins.aerial',
  -- require 'plugins.vim-tmux-navigator',
}, {
  ui = {
    -- If you have a Nerd Font, set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {},
  },
})

-- Function to check if a file exists
local function file_exists(file)
  local f = io.open(file, 'r')
  if f then
    f:close()
    return true
  else
    return false
  end
end

-- Path to the session file
local session_file = '.session.vim'

-- Check if the session file exists in the current directory
if file_exists(session_file) then
  -- Source the session file
  vim.cmd('source ' .. session_file)
end

vim.cmd [[colorscheme gruvbox]]
vim.opt.spell = false
