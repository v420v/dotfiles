return {
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        cmd = {
            "ClaudeCode",
            "ClaudeCodeFocus",
            "ClaudeCodeSend",
            "ClaudeCodeOpen",
            "ClaudeCodeAdd",
            "ClaudeCodeDiffAccept",
            "ClaudeCodeDiffDeny",
            "ClaudeCodeStatus",
        },
        opts = {
            terminal_cmd = vim.fn.executable("claude") == 1 and "claude" or vim.fn.expand("~/.local/bin/claude"),
            auto_start = true,
            log_level = "info",
            terminal = {
                split_side = "right",
                split_width_percentage = 0.35,
                provider = "snacks",
                auto_close = false,
            },
            diff_opts = {
                auto_close_on_accept = true,
                vertical_split = true,
                open_in_current_tab = true,
            },
        },
        keys = {
            { "<leader>cc", "<cmd>ClaudeCode<CR>", mode = "n", desc = "Toggle Claude" },
            { "<leader>cF", "<cmd>ClaudeCodeFocus<CR>", mode = "n", desc = "Focus Claude window" },
            { "<leader>cR", "<cmd>ClaudeCode --resume<CR>", mode = "n", desc = "Resume Claude session" },
            { "<leader>cC", "<cmd>ClaudeCode --continue<CR>", mode = "n", desc = "Continue Claude session" },
            { "<leader>cb", "<cmd>ClaudeCodeAdd %<CR>", mode = "n", desc = "Add current buffer" },
            { "<leader>cs", "<cmd>ClaudeCodeSend<CR>", mode = "v", desc = "Send selection" },
            { "<leader>cs", "<cmd>ClaudeCodeSend<CR>", mode = "n", desc = "Send current line" },
            { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<CR>", mode = "n", desc = "Accept diff" },
            { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<CR>", mode = "n", desc = "Deny diff" },
        },
    },

    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        keys = {
            {
                "<leader>e",
                function()
                    local picker = Snacks.picker.get({ source = "explorer" })[1]
                    if picker then
                        picker:close()
                    else
                        Snacks.explorer()
                    end
                end,
                desc = "Toggle explorer sidebar",
            },
            { "-", function() Snacks.explorer.reveal() end, desc = "Reveal current file in explorer" },
        },
        init = function()
            vim.api.nvim_create_autocmd("VimEnter", {
                desc = "Open explorer sidebar on startup",
                callback = function()
                    if vim.fn.argc() == 0 then return end
                    if vim.fn.isdirectory(vim.fn.argv(0)) == 1 then return end
                    Snacks.explorer.open({ focus = false })
                end,
            })
        end,
        opts = {
            terminal = { win = { border = "rounded" } },
            input = { enabled = true },
            notifier = { enabled = false },
            image = { enabled = true },
            explorer = { replace_netrw = true },
            picker = {
                sources = {
                    explorer = {
                        hidden = true,
                        layout = { preset = "sidebar", layout = { width = 35 } },
                    },
                },
            },
        },
    },
}
