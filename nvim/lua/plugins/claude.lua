local claude_cmd = vim.fn.executable("claude") == 1 and "claude" or vim.fn.expand("~/.local/bin/claude")

local threads = {}
local thread_seq = 0

local function show_thread(term)
    for _, t in ipairs(threads) do
        if t ~= term and t:win_valid() then t:hide() end
    end
    term:show()
    term:focus()
end

local function new_thread()
    require("claudecode")
    thread_seq = thread_seq + 1
    local n = thread_seq
    local term = Snacks.terminal.open(claude_cmd, {
        count = 100 + n,
        env = {
            ENABLE_IDE_INTEGRATION = "true",
            FORCE_CODE_TERMINAL = "true",
            CLAUDE_CODE_SSE_PORT = tostring(require("claudecode.server.init").state.port),
        },
        win = { position = "right", width = 0.35, wo = { winbar = " Claude thread " .. n } },
    })
    vim.b[term.buf].claude_thread = n
    table.insert(threads, term)
    show_thread(term)
end

local function pick_thread()
    threads = vim.tbl_filter(function(t) return t:buf_valid() end, threads)
    if #threads == 0 then return new_thread() end
    local items = vim.list_extend({ unpack(threads) }, { "new" })
    vim.ui.select(items, {
        prompt = "Claude thread",
        format_item = function(t) return t == "new" and "+ New thread" or "Thread " .. vim.b[t.buf].claude_thread end,
    }, function(choice)
        if choice == "new" then
            new_thread()
        elseif choice then
            show_thread(choice)
        end
    end)
end

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
            terminal_cmd = claude_cmd,
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
            { "<leader>co", "<cmd>ClaudeCodeFocus<CR>", mode = "n", desc = "Focus Claude window" },
            { "<leader>cr", "<cmd>ClaudeCode --resume<CR>", mode = "n", desc = "Resume Claude session" },
            { "<leader>cp", "<cmd>ClaudeCode --continue<CR>", mode = "n", desc = "Continue Claude session" },
            { "<leader>cb", "<cmd>ClaudeCodeAdd %<CR>", mode = "n", desc = "Add current buffer" },
            { "<leader>cs", "<cmd>ClaudeCodeSend<CR>", mode = "v", desc = "Send selection" },
            { "<leader>cs", "<cmd>ClaudeCodeSend<CR>", mode = "n", desc = "Send current line" },
            { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<CR>", mode = "n", desc = "Accept diff" },
            { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<CR>", mode = "n", desc = "Deny diff" },
            { "<leader>cn", new_thread, mode = "n", desc = "New Claude thread" },
            { "<leader>ct", pick_thread, mode = "n", desc = "Switch Claude thread" },
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
            {
                "<leader>tt",
                function() Snacks.terminal.toggle(nil, { win = { position = "bottom", height = 0.3 } }) end,
                desc = "Toggle terminal (bottom split)",
            },
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
