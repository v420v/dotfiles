return {
    { "nvim-tree/nvim-web-devicons", lazy = true },

    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            { "<S-h>", "<cmd>BufferLineCyclePrev<CR>", desc = "Prev buffer" },
            { "<S-l>", "<cmd>BufferLineCycleNext<CR>", desc = "Next buffer" },
            { "<leader>bd", function() Snacks.bufdelete() end, desc = "Close buffer" },
            { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Close other buffers" },
        },
        opts = {
            options = {
                mode = "buffers",
                diagnostics = "nvim_lsp",
                always_show_bufferline = true,
                offsets = {
                    {
                        filetype = "snacks_layout_box",
                        text = "EXPLORER",
                        highlight = "Directory",
                        separator = true,
                    },
                    {
                        filetype = "snacks_terminal",
                        text = "CLAUDE CODE",
                        highlight = "Directory",
                        separator = true,
                    },
                },
            },
        },
    },

    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            options = {
                theme = "github_dark_default",
                globalstatus = true,
                component_separators = { left = "", right = "" },
                section_separators = { left = "", right = "" },
            },
            sections = {
                lualine_a = { "mode" },
                lualine_b = {
                    "branch",
                    "diff",
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

    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            signs = {
                add = { text = "▎" },
                change = { text = "▎" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
                untracked = { text = "▎" },
            },
            signs_staged_enable = true,
            signcolumn = true,
            numhl = false,
            linehl = false,
            word_diff = false,
            attach_to_untracked = true,
            current_line_blame = true,
            current_line_blame_opts = {
                virt_text = true,
                virt_text_pos = "eol",
                delay = 400,
                ignore_whitespace = false,
            },
            current_line_blame_formatter = "  <author>, <author_time:%Y-%m-%d> · <summary>",
            preview_config = { border = "rounded", style = "minimal", relative = "cursor", row = 0, col = 1 },
            on_attach = function(buf)
                local gs = package.loaded.gitsigns
                local map = function(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc }) end
                map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
                map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")
                map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
                map("n", "<leader>hi", gs.preview_hunk_inline, "Preview hunk (inline)")
                map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
                map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
                map("n", "<leader>hu", gs.stage_hunk, "Undo stage hunk")
                map("n", "<leader>ha", gs.stage_buffer, "Stage buffer")
                map("n", "<leader>hx", gs.reset_buffer, "Reset buffer")
                map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
                map("n", "<leader>hl", gs.toggle_current_line_blame, "Toggle line blame")
                map("n", "<leader>hd", gs.diffthis, "Diff this")
                map("n", "<leader>hc", function() gs.diffthis("~") end, "Diff this ~")
                map("n", "<leader>hw", gs.toggle_word_diff, "Toggle word diff")
                map("n", "<leader>ht", gs.toggle_deleted, "Toggle deleted lines")
                map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk")
            end,
        },
    },

    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        opts = {
            indent = { char = "▏" },
            scope = { enabled = true, show_start = false, show_end = false },
            exclude = { filetypes = { "help", "alpha", "dashboard", "lazy", "mason", "notify" } },
        },
    },

    {
        "Bekaboo/dropbar.nvim",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
        keys = {
            { "<leader>;", function() require("dropbar.api").pick() end, desc = "Breadcrumbs: pick symbol" },
            {
                "[;",
                function() require("dropbar.api").goto_context_start() end,
                desc = "Breadcrumbs: go to context start",
            },
            {
                "];",
                function() require("dropbar.api").select_next_context() end,
                desc = "Breadcrumbs: select next context",
            },
        },
        opts = {},
    },

    {
        "nvim-treesitter/nvim-treesitter-context",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        keys = {
            { "<leader>ut", "<cmd>TSContext toggle<CR>", desc = "Toggle sticky scroll (treesitter-context)" },
        },
        opts = {
            max_lines = 4,
            multiline_threshold = 1,
            trim_scope = "outer",
            mode = "cursor",
        },
        config = function(_, opts)
            require("treesitter-context").setup(opts)
            local function paint()
                vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "#30363d" })
            end
            paint()
            vim.api.nvim_create_autocmd("ColorScheme", { callback = paint })
        end,
    },

    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "modern",
            spec = {
                { "<leader>f", group = "find" },
                { "<leader>g", group = "git" },
                { "<leader>h", group = "hunk" },
                { "<leader>c", group = "code / claude" },
                { "<leader>b", group = "buffer" },
                { "<leader>t", group = "tab" },
                { "<leader>u", group = "ui" },
            },
        },
    },

    {
        "rcarriga/nvim-notify",
        lazy = true,
        opts = { background_colour = "#000000", render = "compact", stages = "fade", timeout = 2500 },
        init = function()
            vim.notify = function(...) require("notify")(...) end
        end,
    },
}
