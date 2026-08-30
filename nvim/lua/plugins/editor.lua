-- ─── Editor QoL ──────────────────────────────────────────────
-- Tab keymaps
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<CR>",      { desc = "Close tab" })
vim.keymap.set("n", "<leader>tD", "<cmd>windo bdelete<CR>", { desc = "Delete all bufs in tab" })

return {
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

    -- Motion hints: shows available h/j/k/l/w/b… moves as virtual text
    -- (great while learning vim motions). Toggle off once you're fluent.
    {
        "tris203/precognition.nvim",
        event = { "BufReadPost", "BufNewFile" },
        keys = {
            { "<leader>up", "<cmd>Precognition toggle<CR>", desc = "Toggle precognition hints" },
        },
        opts = {
            startVisible = true,
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

    -- Git diff viewer (VSCode/Zed-like source control panel)
    {
        "sindrets/diffview.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFileHistory", "DiffviewRefresh" },
        keys = {
            { "<leader>gd", "<cmd>DiffviewOpen<CR>",          desc = "Diff: open changes" },
            { "<leader>gq", "<cmd>DiffviewClose<CR>",         desc = "Diff: close" },
            { "<leader>gh", "<cmd>DiffviewFileHistory<CR>",   desc = "Diff: repo history" },
            { "<leader>gH", "<cmd>DiffviewFileHistory %<CR>", desc = "Diff: file history" },
            { "<leader>gf", "<cmd>DiffviewToggleFiles<CR>",   desc = "Diff: toggle files panel" },
        },
        opts = {
            enhanced_diff_hl = true,
            view = {
                merge_tool = { layout = "diff3_mixed", disable_diagnostics = true },
            },
            file_panel = {
                listing_style = "tree",
                win_config = { position = "left", width = 35 },
            },
        },
    },
}
