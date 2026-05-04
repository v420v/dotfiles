-- ─── Treesitter ──────────────────────────────────────────────
-- Syntax / indent / folding for every language we touch.
return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    -- Web stack
                    "go", "gomod", "gosum", "gowork",
                    "html", "css", "scss",
                    "javascript", "typescript", "tsx",
                    "json", "jsonc", "yaml", "toml",
                    -- Low-level
                    "c", "cpp", "asm", "make", "cmake",
                    -- Project / config
                    "lua", "vim", "vimdoc", "query",
                    "bash", "nix", "markdown", "markdown_inline",
                    "diff", "git_config", "gitcommit", "gitignore", "gitattributes",
                    "regex", "comment",
                },
                -- Off: NixOS doesn't always have a C compiler on PATH outside
                -- the dev shell, and we don't want a failing :TSInstall on every
                -- buffer. `ensure_installed` runs once at setup; everything else
                -- is on-demand via :TSInstall.
                auto_install = false,
                highlight = { enable = true, additional_vim_regex_highlighting = false },
                indent    = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection    = "<C-Space>",
                        node_incremental  = "<C-Space>",
                        scope_incremental = false,
                        node_decremental  = "<BS>",
                    },
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                            ["aa"] = "@parameter.outer",
                            ["ia"] = "@parameter.inner",
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start     = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
                        goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
                    },
                },
            })
        end,
    },
}
