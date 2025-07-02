return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        -- main = "nvim-treesitter.configs", -- Sets main module to use for opts
        -- -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
        -- opts = {
        --     ensure_installed = {
        --             "bash",
        --             "c",
        --             "diff",
        --             "html",
        --             "lua",
        --             "luadoc",
        --             "markdown",
        --             "markdown_inline",
        --             "query",
        --             "vim",
        --             "vimdoc",
        --             "cpp",
        --             "cmake",
        --             "make",
        --             "python",
        --             "devicetree",
        --             "json",
        --             -- "javascript",
        --             -- "typescript",
        --             -- "tsx",
        --             "yaml",
        --             -- "css",
        --             -- "svelte",
        --             -- "graphql",
        --             "dockerfile",
        --             "gitignore",
        --     },
        --     -- Autoinstall languages that are not installed
        --     auto_install = true,
        --     highlight = {
        --         enable = true,
        --         -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --         --  If you are experiencing weird indenting issues, add the language to
        --         --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        --         additional_vim_regex_highlighting = { "ruby" },
        --     },
        --     indent = { enable = true, disable = { "ruby" } },
        -- },
        -- There are additional nvim-treesitter modules that you can use to interact
        -- with nvim-treesitter. You should go explore a few and see what interests you:
        --
        --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
        --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
        --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects

        config = function()
            local configs = require("nvim-treesitter.configs")
            -- require("nvim-treesitter").setup({
            configs.setup({
                -- enable syntax highlighting
                highlight = {
                    enable = true,
                },
                -- enable indentation
                indent = { enable = true },
                -- enable autotagging (w/ nvim-ts-autotag plugin)
                autotag = { enable = true },
                -- ensure these language parsers are installed
                ensure_installed = {
                    "bash",
                    "c",
                    "diff",
                    "html",
                    "lua",
                    "luadoc",
                    "markdown",
                    "markdown_inline",
                    "query",
                    "vim",
                    "vimdoc",
                    "cpp",
                    "cmake",
                    "make",
                    "python",
                    "devicetree",
                    "json",
                    -- "javascript",
                    -- "typescript",
                    -- "tsx",
                    "yaml",
                    -- "css",
                    -- "svelte",
                    -- "graphql",
                    "dockerfile",
                    "gitignore",
                },
                sync_install = false,
                ignore_install = {""},
                -- auto install above language parsers
                auto_install = true,
            })
        end,
    }
}
