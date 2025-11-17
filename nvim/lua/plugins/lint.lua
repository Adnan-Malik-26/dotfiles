-- Linting Configuration
local lint = require("lint")

lint.linters_by_ft = {
	javascript = { "eslint_d" },
	javascriptreact = { "eslint_d" },
	typescript = { "eslint_d" },
	typescriptreact = { "eslint_d" },
	python = { "ruff" },
	markdown = { "markdownlint" },
	cpp = { "cpplint" },
	solidity = { "solhint" },
	go = { "golangci-lint" },
	css = { "stylelint" },
	html = { "htmlhint" },
	rust = { "clippy" },
}

lint.try_lint()
