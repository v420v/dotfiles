-- ─── Claude Code ── coder/claudecode.nvim ────────────────────
-- Talks to the system `claude` CLI (NixOS provides it as
-- `claude-code` in environment.systemPackages). Opens an
-- interactive Claude session in a side terminal, and exposes
-- @-mention / file-send / diff-review keymaps.
return {
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },          -- terminal provider
        cmd = {
            "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSend",
            "ClaudeCodeOpen", "ClaudeCodeAdd", "ClaudeCodeDiffAccept",
            "ClaudeCodeDiffDeny", "ClaudeCodeStatus",
        },
        opts = {
            terminal_cmd = "claude",                     -- NixOS claude-code binary name
            auto_start   = true,
            log_level    = "info",
            terminal     = {
                split_side       = "right",
                split_width_percentage = 0.35,
                provider         = "snacks",             -- nicer than the native term split
                auto_close       = false,
            },
            diff_opts = {
                auto_close_on_accept = true,
                vertical_split       = true,
                open_in_current_tab  = true,
            },
        },
        keys = {
            { "<leader>cc", "<cmd>ClaudeCode<CR>",          mode = "n", desc = "Toggle Claude" },
            { "<leader>cf", "<cmd>ClaudeCodeFocus<CR>",     mode = "n", desc = "Focus Claude window" },
            { "<leader>cR", "<cmd>ClaudeCode --resume<CR>", mode = "n", desc = "Resume Claude session" },
            { "<leader>cC", "<cmd>ClaudeCode --continue<CR>", mode = "n", desc = "Continue Claude session" },
            -- File / selection context
            { "<leader>cb", "<cmd>ClaudeCodeAdd %<CR>",     mode = "n", desc = "Add current buffer" },
            { "<leader>cs", "<cmd>ClaudeCodeSend<CR>",      mode = "v", desc = "Send selection" },
            -- Diff actions inside Claude-opened diffs
            { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<CR>",mode = "n", desc = "Accept diff" },
            { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<CR>",  mode = "n", desc = "Deny diff" },
        },
    },

    -- Required terminal provider
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            terminal = { win = { border = "rounded" } },
            input    = { enabled = true },
            notifier = { enabled = false },          -- nvim-notify already wired
        },
    },
}
