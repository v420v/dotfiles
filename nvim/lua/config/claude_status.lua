-- Claude Code の状態を lualine に常時表示する。
-- 状態ファイルは ~/.claude/hooks/status.sh（dotfiles/claude/hooks/status.sh）が書く。
local M = {}

local dir = (vim.env.XDG_CACHE_HOME or (vim.env.HOME .. "/.cache")) .. "/claude-status"
local cache = {}
local prev_waiting = 0

local icons = {
    working = { "●", "ClaudeWorking" },
    waiting = { "◉", "ClaudeWaiting" }, -- 許可待ち・質問待ち（あなたの番）
    done = { "✓", "ClaudeDone" },
    idle = { "○", "ClaudeIdle" },
}

local function read()
    local out = {}
    for _, path in ipairs(vim.fn.glob(dir .. "/*.json", true, true)) do
        local fh = io.open(path, "r")
        if fh then
            local ok, data = pcall(vim.json.decode, fh:read("*a"))
            fh:close()
            if ok and type(data) == "table" and data.state then table.insert(out, data) end
        end
    end
    table.sort(out, function(a, b) return tostring(a.key) < tostring(b.key) end)
    return out
end

-- 「あなたの番」のスレッド数
function M.waiting_count()
    local n = 0
    for _, s in ipairs(cache) do
        if s.state == "waiting" then n = n + 1 end
    end
    return n
end

-- hook から `nvim --server $NVIM --remote-expr` で呼ばれる。タイマーからも呼ぶ。
function M.refresh()
    cache = read()
    local now = M.waiting_count()
    if now > prev_waiting then
        vim.schedule(
            function() vim.notify("Claude が入力待ちです", vim.log.levels.WARN, { title = "Claude Code" }) end
        )
    end
    prev_waiting = now
    vim.schedule(function() vim.cmd.redrawstatus() end)
    return true
end

-- lualine 用コンポーネント：  1● 2◉ 3✓ のように並べる
function M.component()
    if #cache == 0 then return "" end
    local parts = {}
    for _, s in ipairs(cache) do
        local ic = icons[s.state] or icons.idle
        local label = tonumber(s.key) and tostring(s.key) or vim.fn.fnamemodify(s.cwd or "?", ":t")
        parts[#parts + 1] = string.format("%%#%s#%s %s%%*", ic[2], label, ic[1])
    end
    return " " .. table.concat(parts, " ")
end

function M.setup(opts)
    opts = opts or {}
    local function paint()
        vim.api.nvim_set_hl(0, "ClaudeWorking", { fg = "#58a6ff", bold = true })
        vim.api.nvim_set_hl(0, "ClaudeWaiting", { fg = "#d29922", bold = true })
        vim.api.nvim_set_hl(0, "ClaudeDone", { fg = "#3fb950", bold = true })
        vim.api.nvim_set_hl(0, "ClaudeIdle", { fg = "#7d8590" })
    end
    paint()
    vim.api.nvim_create_autocmd("ColorScheme", { callback = paint })

    -- herdr 等 nvim の外で動く claude 用の保険（$NVIM が無いのでプッシュされない）
    local timer = vim.uv.new_timer()
    timer:start(0, opts.poll_ms or 3000, vim.schedule_wrap(M.refresh))
end

return M
