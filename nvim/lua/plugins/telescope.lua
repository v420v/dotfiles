-- ─── Telescope ── fuzzy everything ───────────────────────────
-- Reuses fd + ripgrep already installed system-wide.

-- Absolute paths of files with uncommitted git changes (modified,
-- staged, renamed or untracked) — used to flag them in find_files.
local function git_modified_set()
    local root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
    local set = {}
    if vim.v.shell_error ~= 0 or not root or root == "" then
        return set
    end
    local out = vim.fn.systemlist(
        "git -C " .. vim.fn.shellescape(root) .. " status --porcelain --untracked-files=all"
    )
    for _, line in ipairs(out) do
        local p = line:sub(4)                     -- strip the 3-char status column
        local arrow = p:find(" %-> ")             -- renames come as "old -> new"
        if arrow then p = p:sub(arrow + 4) end
        p = p:gsub('^"', ""):gsub('"$', "")       -- unquote paths containing spaces
        set[root .. "/" .. p] = true
    end
    return set
end

-- find_files, but git-changed files get a "●" marker + yellow line so the
-- file you were just editing jumps out (VSCode git-tab vibes, inline).
local function find_files_git_highlight()
    local builtin    = require("telescope.builtin")
    local make_entry = require("telescope.make_entry")
    local modified   = git_modified_set()

    local opts = { hidden = true }
    local base = make_entry.gen_from_file(opts)
    opts.entry_maker = function(line)
        local entry = base(line)
        if not entry then return entry end
        local abs    = vim.fn.fnamemodify(entry.path or entry.value, ":p")
        local is_mod = modified[abs] == true
        local orig_display = entry.display
        entry.display = function(e)
            local text, hls = orig_display(e)
            local prefix = is_mod and "● " or "  "
            local shifted = {}
            if is_mod then
                -- colour the whole line first, so devicon colours layer on top
                shifted[1] = { { 0, #prefix + #text }, "TelescopeGitModified" }
            end
            for _, h in ipairs(hls or {}) do      -- shift devicon hls past the prefix
                table.insert(shifted, { { h[1][1] + #prefix, h[1][2] + #prefix }, h[2] })
            end
            return prefix .. text, shifted
        end
        return entry
    end
    builtin.find_files(opts)
end

-- git_status picker, but each entry gets its filetype devicon prepended — the
-- builtin only shows the git status column, so file kinds are otherwise
-- indistinguishable. Mirrors the find_files display-wrap above.
local function git_status_with_icons()
    local builtin    = require("telescope.builtin")
    local make_entry = require("telescope.make_entry")
    local utils      = require("telescope.utils")

    -- gen_from_git_status bakes entry.path from opts.cwd at entry-creation time,
    -- but telescope only resolves cwd on an internal *copy* of opts — this
    -- closure would see cwd=nil and Path:new({nil, file}) collapses to just the
    -- repo dir, dropping the filename. So resolve the git root ourselves first.
    local opts = {}
    local dir  = vim.fn.expand("%:p:h")
    local root = vim.fn.systemlist({ "git", "-C", dir ~= "" and dir or ".", "rev-parse", "--show-toplevel" })[1]
    if vim.v.shell_error == 0 and root and root ~= "" then opts.cwd = root end

    local base = make_entry.gen_from_git_status(opts)
    opts.entry_maker = function(line)
        local entry = base(line)
        if not entry then return entry end
        local orig_display = entry.display
        entry.display = function(e)
            local text, hls    = orig_display(e)
            local icon, icon_hl = utils.get_devicons(e.value)
            if not icon or icon == "" then return text, hls end
            local prefix  = icon .. " "
            local shifted = {}
            if icon_hl then shifted[1] = { { 0, #icon }, icon_hl } end
            for _, h in ipairs(hls or {}) do      -- shift git-status hls past the icon
                table.insert(shifted, { { h[1][1] + #prefix, h[1][2] + #prefix }, h[2] })
            end
            return prefix .. text, shifted
        end
        return entry
    end
    builtin.git_status(opts)
end

return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            "nvim-telescope/telescope-live-grep-args.nvim",
        },
        keys = {
            { "<leader>ff", find_files_git_highlight,                        desc = "Find files (git changes flagged)" },
            { "<leader>fF", "<cmd>Telescope find_files<CR>",                 desc = "Find files (plain)" },
            { "<leader>fg", "<cmd>Telescope live_grep_args<CR>",             desc = "Live grep (rg flags ok)" },
            {
                "<leader>fG",
                function()
                    require("telescope").extensions.live_grep_args.live_grep_args({ default_text = "-w " })
                end,
                desc = "Live grep (whole word)",
            },
            {
                "<leader>fi",
                function()
                    require("telescope").extensions.live_grep_args.live_grep_args({ default_text = "-i " })
                end,
                desc = "Live grep (case insensitive)",
            },
            {
                "<leader>fI",
                function()
                    require("telescope").extensions.live_grep_args.live_grep_args({ default_text = "-s " })
                end,
                desc = "Live grep (case sensitive)",
            },
            { "<leader>fb", "<cmd>Telescope buffers<CR>",                    desc = "Buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<CR>",                  desc = "Help tags" },
            { "<leader>fr", "<cmd>Telescope oldfiles<CR>",                   desc = "Recent files" },
            { "<leader>fc", "<cmd>Telescope commands<CR>",                   desc = "Commands" },
            { "<leader>fk", "<cmd>Telescope keymaps<CR>",                    desc = "Keymaps" },
            { "<leader>fd", "<cmd>Telescope diagnostics<CR>",                desc = "Diagnostics" },
            { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>",       desc = "Document symbols" },
            { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<CR>",      desc = "Workspace symbols" },
            { "<leader>fw", "<cmd>Telescope grep_string<CR>",                desc = "Grep word under cursor" },
            {
                "<leader>fW",
                function()
                    require("telescope.builtin").grep_string({ word_match = "-w" })
                end,
                desc = "Grep WORD (exact) under cursor",
            },
            { "<leader>/",  "<cmd>Telescope current_buffer_fuzzy_find<CR>",  desc = "Fuzzy in buffer" },
            { "<leader>gc", "<cmd>Telescope git_commits<CR>",                desc = "Git commits" },
            { "<leader>gs", git_status_with_icons,                           desc = "Git status (with file icons)" },
        },
        config = function()
            -- Yellow (modus-vivendi) marker colour for git-changed files in find_files.
            -- Re-applied on colorscheme changes so it survives theme reloads.
            local function set_git_hl()
                vim.api.nvim_set_hl(0, "TelescopeGitModified", { fg = "#d0bc00", bold = true })
            end
            set_git_hl()
            vim.api.nvim_create_autocmd("ColorScheme", { callback = set_git_hl })

            local telescope = require("telescope")
            local actions   = require("telescope.actions")
            local action_state = require("telescope.actions.state")
            local lga_actions = require("telescope-live-grep-args.actions")

            -- Send the picked file(s) to Claude Code as @-mentions.
            -- Honours multi-selection (<Tab> to mark) and falls back to the
            -- entry under the cursor. send_at_mention queues + launches Claude
            -- if it isn't running yet.
            local function send_to_claude(prompt_bufnr)
                local ok, claudecode = pcall(require, "claudecode")
                if not ok then
                    vim.notify("claudecode.nvim not available", vim.log.levels.WARN)
                    return
                end
                local picker  = action_state.get_current_picker(prompt_bufnr)
                local entries = picker:get_multi_selection()
                if vim.tbl_isempty(entries) then
                    entries = { action_state.get_selected_entry() }
                end
                actions.close(prompt_bufnr)
                local n = 0
                for _, entry in ipairs(entries) do
                    local path = entry and (entry.path or entry.filename or entry.value)
                    if path then
                        claudecode.send_at_mention(vim.fn.fnamemodify(path, ":p"))
                        n = n + 1
                    end
                end
                if n > 0 then
                    vim.notify(("Sent %d file%s to Claude"):format(n, n == 1 and "" or "s"))
                end
            end

            telescope.setup({
                defaults = {
                    prompt_prefix = "❯ ",
                    selection_caret = "▶ ",
                    path_display = { "truncate" },
                    file_ignore_patterns = { "%.git/", "node_modules/", "%.cache/", "target/" },
                    mappings = {
                        i = {
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-a>"] = send_to_claude,   -- send picked file(s) to Claude
                            ["<Esc>"] = actions.close,
                        },
                        n = {
                            ["<C-a>"] = send_to_claude,   -- send picked file(s) to Claude
                        },
                    },
                },
                pickers = {
                    find_files = { hidden = true },
                    live_grep  = { additional_args = function() return { "--hidden" } end },
                },
                extensions = {
                    fzf = {
                        fuzzy            = true,
                        override_generic_sorter = true,
                        override_file_sorter    = true,
                        case_mode        = "smart_case",
                    },
                    live_grep_args = {
                        auto_quoting = true,
                        mappings = {
                            i = {
                                ["<C-q>"] = lga_actions.quote_prompt(),
                                ["<C-t>"] = lga_actions.quote_prompt({ postfix = " --type=" }),
                                ["<C-g>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                                ["<C-space>"] = lga_actions.to_fuzzy_refine,
                            },
                        },
                    },
                },
            })
            pcall(telescope.load_extension, "fzf")
            pcall(telescope.load_extension, "live_grep_args")
        end,
    },
}
