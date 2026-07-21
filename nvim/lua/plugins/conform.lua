-- Code Formatting Configuration
require("conform").setup({
	formatters_by_ft = {
		javascript = { "prettierd", "prettier" },
		javascriptreact = { "prettierd", "prettier" },
		typescript = { "prettierd", "prettier" },
		typescriptreact = { "prettierd", "prettier" },

		json = { "prettierd" },
		jsonc = { "prettierd" },
		css = { "prettierd" },
		html = { "prettierd" },
		markdown = { "prettierd" },
	},

	format_on_save = {
		timeout_ms = 1000,
		lsp_fallback = false,
	},
})
