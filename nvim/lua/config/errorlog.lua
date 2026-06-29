-- ─── Error / warning log ─────────────────────────────────────
-- Mirrors nvim runtime errors (vim.notify WARN+ERROR) and LSP
-- diagnostics into a flat log file, so external tools like
-- Claude Code can read them without opening nvim.

local log_path = vim.fn.stdpath("cache") .. "/error.log"
local MAX_LINES = 10000  -- hard cap; oldest lines are dropped when exceeded

local function timestamp()
    return os.date("%Y-%m-%dT%H:%M:%S")
end

local function append(lines)
    if #lines == 0 then return end
    local file = io.open(log_path, "a")
    if not file then return end
    for _, line in ipairs(lines) do
        file:write(line .. "\n")
    end
    file:close()
end

-- Wrap vim.notify so WARN/ERROR messages also land in the log.
-- Returns a new function that logs WARN/ERROR and delegates to `base`.
local function make_logging_notify(base)
    return function(msg, level, opts)
        level = level or vim.log.levels.INFO
        if type(msg) == "string" and level >= vim.log.levels.WARN then
            local label = level >= vim.log.levels.ERROR and "ERROR" or "WARN"
            append({ string.format("[%s] [notify:%s] %s",
                timestamp(), label, (msg:gsub("\n", " | "))) })
        end
        return base(msg, level, opts)
    end
end

vim.notify = make_logging_notify(vim.notify)

local group = vim.api.nvim_create_augroup("ErrorLog", { clear = true })

-- Re-assert the wrapper after lazy.nvim finishes loading plugins.
-- Some plugins (e.g. nvim-notify) replace vim.notify outright in their
-- `init` callbacks, silently dropping this logging layer.
vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    once    = true,
    group   = group,
    callback = function()
        vim.notify = make_logging_notify(vim.notify)
    end,
})

-- Snapshot LSP diagnostics for a buffer shortly after :write,
-- giving the language server a moment to report against the
-- new contents.
local severity_label = {
    [vim.diagnostic.severity.ERROR] = "ERROR",
    [vim.diagnostic.severity.WARN]  = "WARN",
}

-- Last-written diagnostic set per file (keyed by content without timestamp,
-- so repeated saves with identical diagnostics do not grow the log).
local last_snapshot = {}

local function snapshot_buffer(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname == "" then return end

    -- Build current diagnostic set as content strings (no timestamp).
    local current = {}
    for _, d in ipairs(vim.diagnostic.get(bufnr)) do
        local label = severity_label[d.severity]
        if label then
            local key = string.format("[lsp:%s] %s:%d:%d: %s",
                label, fname, d.lnum + 1, d.col + 1,
                (d.message:gsub("\n", " | ")))
            current[key] = true
        end
    end

    -- Skip rewrite when diagnostics haven't changed since the last save.
    local prev = last_snapshot[fname] or {}
    local same = true
    for k in pairs(current) do
        if not prev[k] then same = false; break end
    end
    if same then
        for k in pairs(prev) do
            if not current[k] then same = false; break end
        end
    end
    if same then return end
    last_snapshot[fname] = current

    -- Rewrite the log: drop old entries for this file, then append fresh set.
    -- This prevents duplicate growth and ensures stale diagnostics are pruned.
    local kept = {}
    local lsp_prefix = "] " .. fname .. ":"
    local f = io.open(log_path, "r")
    if f then
        for line in f:lines() do
            if not (line:find(" [lsp:", 1, true) and line:find(lsp_prefix, 1, true)) then
                table.insert(kept, line)
            end
        end
        f:close()
    end

    local ts = timestamp()
    for key in pairs(current) do
        table.insert(kept, string.format("[%s] %s", ts, key))
    end

    -- Apply hard size cap: keep the most recent MAX_LINES lines.
    if #kept > MAX_LINES then
        local trimmed = {}
        for i = #kept - MAX_LINES + 1, #kept do
            table.insert(trimmed, kept[i])
        end
        kept = trimmed
    end

    local out = io.open(log_path, "w")
    if not out then return end
    for _, line in ipairs(kept) do
        out:write(line .. "\n")
    end
    out:close()
end

vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function(args)
        local bufnr = args.buf
        vim.defer_fn(function() snapshot_buffer(bufnr) end, 300)
    end,
})

-- :ErrorLogPath  — print the log path
-- :ErrorLogClear — truncate the log
-- :ErrorLogDump  — append a snapshot of all current diagnostics
vim.api.nvim_create_user_command("ErrorLogPath", function()
    vim.notify(log_path)
end, {})

vim.api.nvim_create_user_command("ErrorLogClear", function()
    local file = io.open(log_path, "w")
    if file then file:close() end
    -- Reset per-file cache so subsequent saves re-log diagnostics.
    last_snapshot = {}
    vim.notify("Cleared " .. log_path)
end, {})

vim.api.nvim_create_user_command("ErrorLogDump", function()
    local lines = {}
    for _, d in ipairs(vim.diagnostic.get()) do
        local label = severity_label[d.severity]
        if label then
            local fname = vim.api.nvim_buf_get_name(d.bufnr)
            if fname ~= "" then
                table.insert(lines, string.format(
                    "[%s] [lsp:%s] %s:%d:%d: %s",
                    timestamp(), label, fname,
                    d.lnum + 1, d.col + 1, (d.message:gsub("\n", " | "))))
            end
        end
    end
    append(lines)
    vim.notify(string.format("Wrote %d entries to %s", #lines, log_path))
end, {})

return { log_path = log_path }
