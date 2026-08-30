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
            { "<leader>cF", "<cmd>ClaudeCodeFocus<CR>",     mode = "n", desc = "Focus Claude window" },
            { "<leader>cR", "<cmd>ClaudeCode --resume<CR>", mode = "n", desc = "Resume Claude session" },
            { "<leader>cC", "<cmd>ClaudeCode --continue<CR>", mode = "n", desc = "Continue Claude session" },
            -- File / selection context
            { "<leader>cb", "<cmd>ClaudeCodeAdd %<CR>",     mode = "n", desc = "Add current buffer" },
            { "<leader>cs", "<cmd>ClaudeCodeSend<CR>",      mode = "v", desc = "Send selection" },
            -- Normal mode: sends the current line in a code buffer.
            { "<leader>cs", "<cmd>ClaudeCodeSend<CR>",      mode = "n", desc = "Send current line" },
            -- Diff actions inside Claude-opened diffs
            { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<CR>",mode = "n", desc = "Accept diff" },
            { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<CR>",  mode = "n", desc = "Deny diff" },
        },
    },

    -- Terminal provider for Claude + file explorer sidebar (VSCode/Zed-style)
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        keys = {
            {
                "<leader>e",
                function()
                    local picker = Snacks.picker.get({ source = "explorer" })[1]
                    if picker then picker:close() else Snacks.explorer() end
                end,
                desc = "Toggle explorer sidebar",
            },
            { "-", function() Snacks.explorer.reveal() end, desc = "Reveal current file in explorer" },
        },
        init = function()
            -- Open the sidebar on startup when launched with a file
            -- (`nvim foo.lua`). Bare `nvim` keeps the alpha dashboard, and
            -- directory args (`nvim .`) are handled by replace_netrw below.
            vim.api.nvim_create_autocmd("VimEnter", {
                desc = "Open explorer sidebar on startup",
                callback = function()
                    if vim.fn.argc() == 0 then return end
                    if vim.fn.isdirectory(vim.fn.argv(0)) == 1 then return end
                    Snacks.explorer.open({ focus = false })  -- keep cursor in the file
                end,
            })
        end,
        opts = {
            terminal = { win = { border = "rounded" } },
            input    = { enabled = true },
            notifier = { enabled = false },          -- nvim-notify already wired
            image    = { enabled = true },           -- inline image previews via kitty graphics protocol
            explorer = { replace_netrw = true },     -- `nvim .` opens the explorer, not netrw
            picker   = {
                sources = {
                    explorer = {
                        hidden = true,               -- show dotfiles
                        layout = { preset = "sidebar", layout = { width = 35 } },
                        -- defaults already: left position, tree view, git status,
                        -- follow current file, stays open when opening files
                    },
                },
            },
        },
    },
}
