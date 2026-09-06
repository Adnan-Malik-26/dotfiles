require("typescript-tools").setup({
	settings = {
		tsserver_path = vim.fn.expand("~/.nvm/versions/node/v26.3.1/lib/node_modules/typescript/lib/tsserver.js"),
		expose_as_code_action = "all",
		tsserver_file_preferences = {
			includeInlayParameterNameHints = "all",
			includeInlayFunctionLikeReturnTypeHints = true,
			includeInlayVariableTypeHints = false,
		},
	},
	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
})
