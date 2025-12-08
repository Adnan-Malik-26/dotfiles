-- LSP Configuration
-- Custom LSP server configurations
vim.lsp.config["ts_ls"] = {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_dir = vim.fs.root(0, { "package.json", "tsconfig.json", "jsconfig.json", ".git" }) or vim.fn.getcwd(),
}

vim.lsp.config["solidity-language-server"] = {
	cmd = { "solidity-language-server", "--stdio" },
	filetypes = { "solidity" },
	root_dir = vim.fs.root(0, { "hardhat.config.js", "truffle-config.js", ".git" }) or vim.fn.getcwd(),
}

-- Enable LSP servers
vim.lsp.enable({
	"lua_ls",
	"ts_ls",
	"marksman",
	"clangd",
	"tailwindcss",
	"gopls",
	"html",
	"cssls",
	"hyprls",
	"tinymist",
	"ruff",
	"svelte",
	"biome",
	"qmlls",
})

-- LSP signature configuration
require("lsp_signature").setup({
	bind = true,
	handler_sets = { border = "rounded" },
	transparent_background = true,
})

-- Mason
require("mason").setup()

-- LazyDev for Lua development
require("lazydev").setup()
