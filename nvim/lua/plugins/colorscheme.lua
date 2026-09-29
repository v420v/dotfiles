-- ─── Colorscheme ── GitHub Dark ──────────────────────────────
return {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    priority = 1000,
    lazy = false,
    opts = {
        options = {
            transparent = false,
            dim_inactive = false,
            hide_nvim_statusline = false,
            styles = {
                comments = "italic",
                keywords = "bold",
                functions = "NONE",
                variables = "NONE",
            },
        },
        groups = {
            all = {
                -- Snacks explorer dims untracked files (links NonText); show them
                -- green like VSCode/Zed. `git.add` = the gitsigns gutter green.
                SnacksPickerGitStatusUntracked = { fg = "git.add" },
            },
        },
    },
    config = function(_, opts)
        require("github-theme").setup(opts)
        vim.cmd.colorscheme("github_dark_default")
    end,
}
