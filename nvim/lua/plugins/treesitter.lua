require("tree-sitter-manager").setup({
    ensure_installed = {
        -- Web
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "scss",
        "json",
        -- "jsonc",
        "yaml",
        "toml",

        -- Shell
        "bash",

        -- Markdown
        "markdown",
        "markdown_inline",

        -- Lua
        "lua",
        "vim",
        "vimdoc",
        "query",

        -- Other languages you use
        "go",
        "rust",
        "c",
        "cpp",
        "svelte",
        "vue",
        "regex",
        "latex",
    },

    auto_install = true,

    highlight = {
        enable = true,
    },

    indent = {
        enable = true,
    },
})

vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        pcall(vim.treesitter.start)
    end,
})
