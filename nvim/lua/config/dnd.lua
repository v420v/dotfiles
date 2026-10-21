-- Drag & drop from Finder into the snacks explorer.
--
-- kitty >= 0.47 speaks a terminal DnD protocol (OSC 72, see
-- https://sw.kovidgoyal.net/kitty/dnd-protocol/): once we opt in, it streams the
-- drag position as cell coordinates, then delivers the dropped text/uri-list on
-- request. That gives us VS Code / Zed behaviour: hovering a closed folder for a
-- moment expands it, and the drop goes into the folder under the mouse.
--
-- Outside the explorer (or in a terminal without the protocol) a drop degrades
-- to the plain paste kitty always did; `vim.paste` below turns a paste of
-- existing paths inside the explorer into a copy.

local M = {}

local HOLD_MS = 500 -- hover time before a folder springs open
local OSC = "\27]72;"
local ST = "\27\\"

local state = {
    accepted = false, -- told kitty we take this drag
    hover = nil, ---@type string? path of the folder being hovered
    timer = nil, ---@type uv.uv_timer_t?
    target = nil, ---@type string? directory to copy into on drop
    chunks = {}, ---@type string[] base64 pieces of the uri-list
}

local function send(meta, payload)
    local seq = OSC .. meta .. (payload and (";" .. payload) or "") .. ST
    pcall(vim.api.nvim_ui_send, seq)
end

local function explorer()
    local picker = Snacks.picker.get({ source = "explorer" })[1]
    if picker and not picker.closed and picker.list.win:valid() then return picker end
end

--- Explorer item under a screen cell (0-based kitty coordinates).
local function item_at(picker, x, y)
    local win = picker.list.win.win
    local top, left = unpack(vim.fn.win_screenpos(win))
    local row, col = y + 1 - top + 1, x + 1 - left + 1
    if row < 1 or row > vim.api.nvim_win_get_height(win) then return end
    if col < 1 or col > vim.api.nvim_win_get_width(win) then return end
    return picker.list.visible[row], picker.list:row2idx(row)
end

local function stop_timer()
    if state.timer then
        state.timer:stop()
        state.timer:close()
        state.timer = nil
    end
    state.hover = nil
end

--- Copy files into dir and show them in the explorer.
function M.copy_into(picker, files, dir)
    Snacks.picker.util.copy(files, dir)
    local Tree = require("snacks.explorer.tree")
    Tree:refresh(dir)
    Tree:open(dir)
    require("snacks.explorer.actions").update(picker, { target = dir })
    Snacks.notify.info(("Copied %d item(s) to `%s`"):format(#files, dir))
end

local function on_move(picker, x, y)
    local item, idx = item_at(picker, x, y)
    if not item then return stop_timer() end
    picker.list:move(idx, true)
    local dir = item.dir and not item.open and item.file or nil
    if dir == state.hover then return end
    stop_timer()
    if not dir then return end
    state.hover = dir
    state.timer = vim.defer_fn(function()
        state.timer, state.hover = nil, nil
        local p = explorer()
        if not p then return end
        require("snacks.explorer.tree"):open(dir)
        require("snacks.explorer.actions").update(p, { refresh = true })
    end, HOLD_MS)
end

--- "file:///a/b%20c/" -> "/a/b c"
local function uri_to_path(uri)
    local path = uri:match("^file://[^/]*(/.*)$")
    if not path then return end
    path = path:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
    return (path:gsub("/+$", ""))
end

local function on_data_done()
    local files = {}
    local b64 = table.concat(state.chunks)
    b64 = b64 .. ("="):rep((4 - #b64 % 4) % 4) -- kitty sends no padding, nvim requires it
    local ok, text = pcall(vim.base64.decode, b64)
    if not ok then
        state.chunks, state.target = {}, nil
        Snacks.notify.error("Drop failed: could not decode uri list")
        return send("t=r:o=0")
    end
    for line in text:gmatch("[^\r\n]+") do
        local path = line:sub(1, 1) ~= "#" and uri_to_path(line)
        if path and vim.uv.fs_stat(path) then files[#files + 1] = path end
    end
    state.chunks = {}
    local target, picker = state.target, explorer()
    state.target = nil
    if #files == 0 then return send("t=r:o=0") end
    if target and picker then
        M.copy_into(picker, files, target)
    else
        vim.paste(files, -1) -- same as kitty's default drop behaviour
    end
    send("t=r:o=1")
end

local function on_response(seq)
    local meta, payload = seq:match("^\27%]72;([^;]*);?(.*)$")
    if not meta then return end
    payload = payload:gsub("\27\\$", ""):gsub("\7$", "")
    local kv = {}
    for k, v in meta:gmatch("(%w)=([^:]*)") do
        kv[k] = v
    end
    local picker = explorer()

    if kv.t == "m" then -- drag moved (x=y=-1: left the window)
        local x, y = tonumber(kv.x), tonumber(kv.y)
        if x < 0 then
            state.accepted = false
            return stop_timer()
        end
        if not state.accepted then
            state.accepted = true
            send("t=m:o=1", "text/uri-list")
        end
        if picker then on_move(picker, x, y) end
    elseif kv.t == "M" then -- dropped: ask for the uri list
        stop_timer()
        state.accepted = false
        local item = picker and item_at(picker, tonumber(kv.x), tonumber(kv.y))
        state.target = item and Snacks.picker.util.dir(item) or nil
        local idx = 0
        for i, mime in ipairs(vim.split(vim.trim(payload), " ")) do
            if mime == "text/uri-list" then idx = i end
        end
        if idx == 0 then return send("t=r:o=0") end
        state.chunks = {}
        send("t=r:x=" .. idx)
    elseif kv.t == "r" then -- uri list data, ends with an empty payload
        if payload == "" then return on_data_done() end
        state.chunks[#state.chunks + 1] = payload
    elseif kv.t == "R" then
        state.chunks, state.target = {}, nil
        Snacks.notify.error("Drop failed: " .. payload)
        send("t=r:o=0")
    end
end

function M.setup()
    -- vim.paste fallback: pasted paths inside the explorer are copied there
    local paste = vim.paste
    vim.paste = function(lines, phase)
        local picker = vim.bo.filetype == "snacks_picker_list" and explorer()
        local files = vim.tbl_filter(function(l) return l ~= "" end, lines)
        local all_exist = #files > 0 and vim.iter(files):all(function(l) return vim.uv.fs_stat(l) ~= nil end)
        if not (picker and all_exist) then return paste(lines, phase) end
        M.copy_into(picker, files, picker:dir())
        return true
    end

    if not vim.env.KITTY_WINDOW_ID or vim.env.TMUX then return end
    local group = vim.api.nvim_create_augroup("config.dnd", { clear = true })
    vim.api.nvim_create_autocmd("TermResponse", {
        group = group,
        callback = function(ev) on_response(ev.data.sequence) end,
    })
    vim.api.nvim_create_autocmd("VimLeavePre", { group = group, callback = function() send("t=A") end })
    vim.api.nvim_create_autocmd("VimEnter", { group = group, callback = function() send("t=a", "text/uri-list") end })
end

M.setup()
return M
