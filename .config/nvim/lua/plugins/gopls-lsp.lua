-- ~/.config/nvim/lua/plugins/lsp-gopls.lua
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      gopls = {},
    },
  },
}
