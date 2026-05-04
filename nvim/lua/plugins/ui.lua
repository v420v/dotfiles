-- ─── UI bits ── statusline, gitsigns, indent guides, icons ───
return {
    -- Icons (Nerd Font already provided by NixOS fonts.packages)
    { "nvim-tree/nvim-web-devicons", lazy = true },

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme = "catppuccin",
                globalstatus = true,
                component_separators = { left = "", right = "" },
                section_separators   = { left = "", right = "" },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = { "branch", "diff",
                    {
                        "diagnostics",
                        symbols = { error = " ", warn = " ", info = " ", hint = " " },
                    },
                },
                lualine_c = { { "filename", path = 1 } },
                lualine_x = { "encoding", "fileformat", "filetype" },
                lualine_y = { "progress" },
                lualine_z = { "location" },
            },
        },
    },

    -- Git gutter
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add          = { text = "▎" },
                change       = { text = "▎" },
                delete       = { text = "" },
                topdelete    = { text = "" },
                changedelete = { text = "▎" },
                untracked    = { text = "▎" },
            },
            on_attach = function(buf)
                local gs = package.loaded.gitsigns
                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
                end
                map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
                map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")
                map("n", "<leader>hp", gs.preview_hunk,  "Preview hunk")
                map("n", "<leader>hr", gs.reset_hunk,    "Reset hunk")
                map("n", "<leader>hs", gs.stage_hunk,    "Stage hunk")
                map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
                map("n", "<leader>hd", gs.diffthis,      "Diff this")
            end,
        },
    },

    -- Indent guides
    {
        "lukas-reineke/indent-blankline.nvim",
        main  = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        opts  = {
            indent = { char = "▏" },
            scope  = { enabled = true, show_start = false, show_end = false },
            exclude = { filetypes = { "help", "alpha", "dashboard", "lazy", "mason", "notify" } },
        },
    },

    -- Discoverable keymaps
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
            spec = {
                { "<leader>f", group = "find / format" },
                { "<leader>g", group = "git" },
                { "<leader>h", group = "hunk" },
                { "<leader>c", group = "code / claude" },
                { "<leader>b", group = "buffer" },
            },
        },
    },

    -- Nicer notifications + cmdline
    {
        "rcarriga/nvim-notify",
        lazy = true,
        opts = { background_colour = "#1e1e2e", render = "compact", stages = "fade", timeout = 2500 },
        init = function() vim.notify = function(...) require("notify")(...) end end,
    },
}
