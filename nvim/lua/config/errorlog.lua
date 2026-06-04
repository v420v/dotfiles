-- ─── Error / warning log ─────────────────────────────────────
-- Mirrors nvim runtime errors (vim.notify WARN+ERROR) and LSP
-- diagnostics into a flat log file, so external tools like
-- Claude Code can read them without opening nvim.

local log_path = vim.fn.stdpath("cache") .. "/error.log"

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
local original_notify = vim.notify
vim.notify = function(msg, level, opts)
    level = level or vim.log.levels.INFO
    if type(msg) == "string" and level >= vim.log.levels.WARN then
        local label = level >= vim.log.levels.ERROR and "ERROR" or "WARN"
        append({ string.format("[%s] [notify:%s] %s",
            timestamp(), label, (msg:gsub("\n", " | "))) })
    end
    return original_notify(msg, level, opts)
end

-- Snapshot LSP diagnostics for a buffer shortly after :write,
-- giving the language server a moment to report against the
-- new contents.
local severity_label = {
    [vim.diagnostic.severity.ERROR] = "ERROR",
    [vim.diagnostic.severity.WARN]  = "WARN",
}

local function snapshot_buffer(bufnr)
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if fname == "" then return end
    local lines = {}
    for _, d in ipairs(vim.diagnostic.get(bufnr)) do
        local label = severity_label[d.severity]
        if label then
            table.insert(lines, string.format(
                "[%s] [lsp:%s] %s:%d:%d: %s",
                timestamp(), label, fname,
                d.lnum + 1, d.col + 1, (d.message:gsub("\n", " | "))))
        end
    end
    append(lines)
end

local group = vim.api.nvim_create_augroup("ErrorLog", { clear = true })
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
    local f = io.open(log_path, "w")
    if f then f:close() end
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
