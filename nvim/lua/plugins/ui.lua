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
                theme = "modus-vivendi",
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
            signs_staged_enable = true,
            signcolumn          = true,
            numhl               = false,
            linehl              = false,
            word_diff           = false,
            attach_to_untracked = true,
            current_line_blame  = true,
            current_line_blame_opts = {
                virt_text         = true,
                virt_text_pos     = "eol",
                delay             = 400,
                ignore_whitespace = false,
            },
            current_line_blame_formatter = "  <author>, <author_time:%Y-%m-%d> · <summary>",
            preview_config = { border = "rounded", style = "minimal", relative = "cursor", row = 0, col = 1 },
            on_attach = function(buf)
                local gs = package.loaded.gitsigns
                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
                end
                map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
                map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")
                map("n", "<leader>hp", gs.preview_hunk,         "Preview hunk")
                map("n", "<leader>hP", gs.preview_hunk_inline,  "Preview hunk (inline)")
                map("n", "<leader>hr", gs.reset_hunk,           "Reset hunk")
                map("n", "<leader>hs", gs.stage_hunk,           "Stage hunk")
                map("n", "<leader>hu", gs.undo_stage_hunk,      "Undo stage hunk")
                map("n", "<leader>hS", gs.stage_buffer,         "Stage buffer")
                map("n", "<leader>hR", gs.reset_buffer,         "Reset buffer")
                map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
                map("n", "<leader>hB", gs.toggle_current_line_blame, "Toggle line blame")
                map("n", "<leader>hd", gs.diffthis,             "Diff this")
                map("n", "<leader>hD", function() gs.diffthis("~") end, "Diff this ~")
                map("n", "<leader>hw", gs.toggle_word_diff,     "Toggle word diff")
                map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
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
        opts = { background_colour = "#000000", render = "compact", stages = "fade", timeout = 2500 },
        init = function() vim.notify = function(...) require("notify")(...) end end,
    },
}
