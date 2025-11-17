-- Code Formatting Configuration
require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "prettierd", "prettier" },
		javascriptreact = { "prettierd", "prettier" },
		typescriptreact = { "prettierd", "prettier" },
		python = { "black" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		html = { "superhtml" },
		sh = { "shfmt" },
		json = { "prettierd" },
		typst = { "typstyle" },
		go = { "gofmt", "goimports-reviser", "golines" },
	},
	format_on_save = {
		lsp_fallback = true,
		async = false,
		timeout_ms = 1000,
	},
})
