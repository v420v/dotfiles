-- ─── Telescope ── fuzzy everything ───────────────────────────
-- Reuses fd + ripgrep already installed system-wide.
return {
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<CR>",                 desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<CR>",                  desc = "Live grep" },
            { "<leader>fb", "<cmd>Telescope buffers<CR>",                    desc = "Buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<CR>",                  desc = "Help tags" },
            { "<leader>fr", "<cmd>Telescope oldfiles<CR>",                   desc = "Recent files" },
            { "<leader>fc", "<cmd>Telescope commands<CR>",                   desc = "Commands" },
            { "<leader>fk", "<cmd>Telescope keymaps<CR>",                    desc = "Keymaps" },
            { "<leader>fd", "<cmd>Telescope diagnostics<CR>",                desc = "Diagnostics" },
            { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>",       desc = "Document symbols" },
            { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<CR>",      desc = "Workspace symbols" },
            { "<leader>fw", "<cmd>Telescope grep_string<CR>",                desc = "Grep word under cursor" },
            { "<leader>/",  "<cmd>Telescope current_buffer_fuzzy_find<CR>",  desc = "Fuzzy in buffer" },
            { "<leader>gc", "<cmd>Telescope git_commits<CR>",                desc = "Git commits" },
            { "<leader>gs", "<cmd>Telescope git_status<CR>",                 desc = "Git status" },
        },
        config = function()
            local telescope = require("telescope")
            local actions   = require("telescope.actions")
            local action_state = require("telescope.actions.state")

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
                },
            })
            pcall(telescope.load_extension, "fzf")
        end,
    },
}
