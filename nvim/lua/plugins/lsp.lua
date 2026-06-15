-- LSP Configuration

-- Mason bin in PATH
vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

-- Server configurations
vim.lsp.config["ts_ls"] = {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
}

vim.lsp.config["solidity-language-server"] = {
	cmd = { "solidity-language-server", "--stdio" },
	filetypes = { "solidity" },
	root_markers = { "hardhat.config.js", "truffle-config.js", ".git" },
}

vim.lsp.config["lua_ls"] = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".git" },
	settings = {
		Lua = {
			workspace = { library = vim.api.nvim_get_runtime_file("", true) },
			telemetry = { enable = false },
		},
	},
}

vim.lsp.config["clangd"] = {
	cmd = { "clangd" },
	filetypes = { "c", "cpp" },
	root_markers = { "compile_commands.json", "CMakeLists.txt", ".git" },
}

vim.lsp.config["gopls"] = {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_markers = { "go.mod", "go.work", ".git" },
}

vim.lsp.config["marksman"] = {
	cmd = { "marksman", "server" },
	filetypes = { "markdown" },
	root_markers = { ".marksman.toml", ".git" },
}

vim.lsp.config["tailwindcss"] = {
	cmd = { "tailwindcss-language-server", "--stdio" },
	filetypes = {
		"html",
		"css",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"svelte",
	},
	root_markers = { "tailwind.config.js", "tailwind.config.ts", ".git" },
}

vim.lsp.config["html"] = {
	cmd = { "vscode-html-language-server", "--stdio" },
	filetypes = { "html" },
	root_markers = { "package.json", ".git" },
}

vim.lsp.config["cssls"] = {
	cmd = { "vscode-css-language-server", "--stdio" },
	filetypes = { "css", "scss", "less" },
	root_markers = { "package.json", ".git" },
}

vim.lsp.config["hyprls"] = {
	cmd = { "hyprls" },
	filetypes = { "hyprlang" },
	root_markers = { ".git" },
}

vim.lsp.config["tinymist"] = {
	cmd = { "tinymist" },
	filetypes = { "typst" },
	root_markers = { ".git" },
}

vim.lsp.config["ruff"] = {
	cmd = { "ruff", "server" },
	filetypes = { "python" },
	root_markers = { "pyproject.toml", "ruff.toml", ".git" },
}

vim.lsp.config["svelte"] = {
	cmd = { "svelteserver", "--stdio" },
	filetypes = { "svelte" },
	root_markers = { "svelte.config.js", "package.json", ".git" },
}

vim.lsp.config["biome"] = {
	cmd = { "biome", "lsp-proxy" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
		"json",
		"jsonc",
	},
	root_markers = { "biome.json", "biome.jsonc", ".git" },
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
	"solidity-language-server",
})

-- Native signature help
vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help" })

-- Mason
require("mason").setup()
