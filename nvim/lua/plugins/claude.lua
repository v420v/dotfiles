local claude_cmd = vim.fn.executable("claude") == 1 and "claude" or vim.fn.expand("~/.local/bin/claude")

local threads = {}
local thread_seq = 0
local status_dir = (vim.env.XDG_CACHE_HOME or (vim.env.HOME .. "/.cache")) .. "/claude-status"

-- 最後の返答（status.sh が <key>.txt に書く）をクリップボードへ
local function copy_reply(key)
    local fh = io.open(string.format("%s/%s.txt", status_dir, key), "r")
    local text = fh and fh:read("*a") or ""
    if fh then fh:close() end
    if text == "" then return vim.notify("コピーできる返答がありません", vim.log.levels.WARN) end
    vim.fn.setreg("+", text)
    vim.notify(string.format("返答をコピーしました（%d 行）", select(2, text:gsub("\n", "")) + 1))
end

-- winbar の [⧉ Copy] クリック用（minwid にスレッド番号、0 は <leader>cc の Claude）
function _G.ClaudeCopyReply(minwid) copy_reply(minwid == 0 and "main" or tostring(minwid)) end

-- ログイン中アカウントのメール（~/.claude.json の mtime が変わった時だけ読み直す）
local account = { mtime = -1, email = "" }
function _G.ClaudeAccount()
    local path = vim.env.HOME .. "/.claude.json"
    local st = vim.uv.fs_stat(path)
    if st and st.mtime.sec ~= account.mtime then
        account.mtime = st.mtime.sec
        local fh = io.open(path, "r")
        local ok, data = pcall(vim.json.decode, fh and fh:read("*a") or "")
        if fh then fh:close() end
        account.email = ok and type(data) == "table" and vim.tbl_get(data, "oauthAccount", "emailAddress") or ""
    end
    return account.email ~= "" and ("  " .. account.email) or ""
end

local function winbar(label, minwid)
    return string.format(" %s  %%%d@v:lua.ClaudeCopyReply@[⧉ Copy]%%X%%{v:lua.ClaudeAccount()}", label, minwid)
end

vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*claude*",
    desc = "Y で Claude の最後の返答をコピー",
    callback = function(ev)
        vim.keymap.set("n", "Y", function() copy_reply(vim.b[ev.buf].claude_thread or "main") end, {
            buffer = ev.buf,
            desc = "Copy last Claude reply",
        })
    end,
})

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
            CLAUDE_THREAD = tostring(n),
        },
        win = { position = "right", width = 0.35, wo = { winbar = winbar("Claude thread " .. n, n) } },
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
            env = { CLAUDE_THREAD = "main" },
            terminal = {
                split_side = "right",
                split_width_percentage = 0.35,
                provider = "snacks",
                auto_close = false,
                snacks_win_opts = { wo = { winbar = winbar("Claude", 0) } },
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
                        ignored = true,
                        layout = { preset = "sidebar", layout = { width = 35 } },
                    },
                },
            },
        },
    },
}
