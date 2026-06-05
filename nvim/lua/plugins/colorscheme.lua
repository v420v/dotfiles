-- ─── Colorscheme ── Modus Vivendi ────────────────────────────
return {
    "miikanissi/modus-themes.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        style = "modus_vivendi",
        transparent = false,
        dim_inactive = false,
        hide_inactive_statusline = false,
        line_nr_column_background = false,
        sign_column_background = false,
        styles = {
            comments = { italic = true },
            keywords = { bold = true },
            functions = {},
            variables = {},
        },
    },
    config = function(_, opts)
        require("modus-themes").setup(opts)
        vim.cmd.colorscheme("modus_vivendi")
    end,
}
