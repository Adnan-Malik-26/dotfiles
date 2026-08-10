-- Plugin Management Configuration

local github = function(repo, opts)
	return vim.tbl_extend("force", {
		src = "https://github.com/" .. repo,
	}, opts or {})
end

vim.pack.add({
	-- Themes
	github("catppuccin/nvim", { load = false }),
	github("neanias/everforest-nvim", { load = false }),
	github("ellisonleao/gruvbox.nvim", { load = false }),
	github("Mofiqul/dracula.nvim", { load = false }),
	github("shaunsingh/nord.nvim", { load = false }),
	github("kdheepak/monochrome.nvim", { load = false }),
	github("darkvoid-theme/darkvoid.nvim", { load = false }),
	github("oskarnurm/koda.nvim", { load = false }),
	github("rose-pine/neovim", { load = false }),
	github("idr4n/github-monochrome.nvim", { load = false }),
	github("samharju/synthweave.nvim", { load = false }),
	github("Shatur/neovim-ayu", { load = false }),
	github("nyoom-engineering/oxocarbon.nvim", { load = false }),
	github("olivercederborg/poimandres.nvim", { load = false }),
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
	-- github("nvim-telescope/telescope.nvim", { load = false }),
	-- github("nvim-telescope/telescope-fzf-native.nvim", { load = false }),

	-- Editing
	github("nvim-mini/mini.comment"),
	github("nvim-mini/mini.pairs"),

	-- LSP and completion
	github("mason-org/mason.nvim"),
	github("L3MON4D3/LuaSnip"),
	github("rafamadriz/friendly-snippets"),
	github("saghen/blink.cmp", { version = "v1.10.2" }),
	github("Saghen/blink.compat"),
	github("mrcjkb/rustaceanvim", { load = false }),

	-- Code quality
	github("stevearc/conform.nvim"),
	github("mfussenegger/nvim-lint"),
	-- github("nvim-treesitter/nvim-treesitter", { version = "main" }),
	-- github("nvim-treesitter/nvim-treesitter-textobjects", { version = "main" }),
	github("romus204/tree-sitter-manager.nvim"),
	-- github("HiPhish/rainbow-delimiters.nvim", { load = false }),

	-- Utilities
	github("christoomey/vim-tmux-navigator"),
	github("MeanderingProgrammer/render-markdown.nvim"),
	-- github("derektata/lorem.nvim"),
	-- github("chomosuke/typst-preview.nvim", { load = false }),
	-- github("bngarren/checkmate.nvim", { load = false }),

	-- Notes
	github("epwalsh/obsidian.nvim"),
	github("kkharji/sqlite.lua", { load = false }),
	github("apdot/doodle", { load = false }),
})
