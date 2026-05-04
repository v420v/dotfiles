-- ─── Editor QoL ──────────────────────────────────────────────
return {
    -- File explorer in a buffer (vim-vinegar-style: edit the dir)
    {
        "stevearc/oil.nvim",
        cmd  = "Oil",
        keys = {
            { "-",         "<cmd>Oil<CR>", desc = "Open parent directory" },
            { "<leader>e", "<cmd>Oil<CR>", desc = "Open parent directory (oil)" },
        },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            default_file_explorer = true,
            view_options = { show_hidden = true },
            keymaps = {
                ["<C-h>"] = false,                 -- leave for window nav
                ["<C-l>"] = false,
                ["q"]     = "actions.close",
            },
        },
    },

    -- Comments: gcc / gc<motion>
    { "numToStr/Comment.nvim", event = { "BufReadPost", "BufNewFile" }, opts = {} },

    -- Surround: ysiw" / cs"' / ds"
    { "kylechui/nvim-surround", event = "BufReadPost", version = "*", opts = {} },

    -- Auto-pairs that play nice with treesitter
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts  = { check_ts = true, fast_wrap = {} },
    },

    -- Sane buffer-close that keeps window layout
    {
        "echasnovski/mini.bufremove",
        keys = {
            { "<leader>bd", function() require("mini.bufremove").delete(0, false) end, desc = "Delete buffer" },
            { "<leader>bD", function() require("mini.bufremove").delete(0, true)  end, desc = "Delete buffer (force)" },
        },
    },

    -- Highlight TODO / FIXME / NOTE / HACK
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {},
        keys = {
            { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "Find TODOs" },
        },
    },
}
