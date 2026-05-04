-- ─── Colorscheme ── Catppuccin Mocha ─────────────────────────
return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    opts = {
        flavour = "mocha",
        transparent_background = false,
        term_colors = true,
        integrations = {
            cmp           = true,
            gitsigns      = true,
            telescope     = { enabled = true },
            treesitter    = true,
            mason         = false,
            native_lsp    = {
                enabled = true,
                underlines = {
                    errors      = { "undercurl" },
                    hints       = { "undercurl" },
                    warnings    = { "undercurl" },
                    information = { "undercurl" },
                },
            },
            mini          = { enabled = true, indentscope_color = "lavender" },
            indent_blankline = { enabled = true, scope_color = "lavender" },
            which_key     = true,
            notify        = true,
            -- claudecode renders inside terminal buffers; no integration flag needed
        },
    },
    config = function(_, opts)
        require("catppuccin").setup(opts)
        vim.cmd.colorscheme("catppuccin-mocha")
    end,
}
