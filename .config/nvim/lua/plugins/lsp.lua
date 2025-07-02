-- ~/.config/nvim/lua/plugins/gopls.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      gopls = {},
    },
  },
}
