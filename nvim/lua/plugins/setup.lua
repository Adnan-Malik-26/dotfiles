-- Plugin Management Configuration

local github = function(repo, opts)
	return vim.tbl_extend("force", {
		src = "https://github.com/" .. repo,
	}, opts or {})
end

vim.pack.add({
	-- Themes
	github("Adnan-Malik-26/monoknight.nvim", { load = false }),

	-- UI
	github("nvim-tree/nvim-web-devicons"),
	github("brenoprata10/nvim-highlight-colors"),
	github("nvim-lualine/lualine.nvim"),
	github("rcarriga/nvim-notify", { load = false }),
	github("j-hui/fidget.nvim"),
	github("akinsho/bufferline.nvim"),

	-- File management
	github("stevearc/oil.nvim"),
	github("nvim-lua/plenary.nvim"),
	github("folke/snacks.nvim"),

	-- Editing
	github("nvim-mini/mini.comment"),
	github("nvim-mini/mini.pairs"),

	-- LSP and completion
	github("mason-org/mason.nvim"),
	github("L3MON4D3/LuaSnip"),
  github("rafamadriz/friendly-snippets"),
	github("saghen/blink.cmp", { version = "v1.10.2" }),
	github("Saghen/blink.compat"),
  github("pmizio/typescript-tools.nvim"),
  github("windwp/nvim-ts-autotag"),

	-- Code quality
	github("stevearc/conform.nvim"),
	github("mfussenegger/nvim-lint"),
	github("romus204/tree-sitter-manager.nvim"),

	-- Utilities
	github("christoomey/vim-tmux-navigator"),
	github("MeanderingProgrammer/render-markdown.nvim"),
})
