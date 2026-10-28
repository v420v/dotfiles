return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        config = function()
            if vim.fn.has("nvim-0.12") == 1 then
                local tsq = require("vim.treesitter.query")
                local add_directive, add_predicate = tsq.add_directive, tsq.add_predicate
                local function to_single(captures)
                    local single = {}
                    for id, nodes in pairs(captures) do
                        single[id] = type(nodes) == "table" and nodes[#nodes] or nodes
                    end
                    return single
                end
                tsq.add_directive = function(name, handler, opts)
                    return add_directive(
                        name,
                        function(captures, ...) return handler(to_single(captures), ...) end,
                        opts
                    )
                end
                tsq.add_predicate = function(name, handler, opts)
                    return add_predicate(
                        name,
                        function(captures, ...) return handler(to_single(captures), ...) end,
                        opts
                    )
                end
                package.loaded["nvim-treesitter.query_predicates"] = nil
                pcall(require, "nvim-treesitter.query_predicates")
                tsq.add_directive, tsq.add_predicate = add_directive, add_predicate
            end

            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "go",
                    "gomod",
                    "gosum",
                    "gowork",
                    "html",
                    "css",
                    "scss",
                    "javascript",
                    "typescript",
                    "tsx",
                    "vue",
                    "php",
                    "php_only",
                    "phpdoc",
                    "json",
                    "jsonc",
                    "yaml",
                    "toml",
                    "c",
                    "cpp",
                    "asm",
                    "make",
                    "cmake",
                    "v",
                    "lua",
                    "vim",
                    "vimdoc",
                    "query",
                    "bash",
                    "nix",
                    "markdown",
                    "markdown_inline",
                    "diff",
                    "git_config",
                    "gitcommit",
                    "gitignore",
                    "gitattributes",
                    "regex",
                    "comment",
                },
                auto_install = false,
                highlight = { enable = true, additional_vim_regex_highlighting = false },
                indent = { enable = true },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<C-Space>",
                        node_incremental = "<C-Space>",
                        scope_incremental = false,
                        node_decremental = "<BS>",
                    },
                },
            })
        end,
    },

    -- textobjects は main ブランチ（新 API）。nvim-treesitter.configs 経由では設定できないので
    -- setup とキーマップを自前で登録する。
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = { lookahead = true },
                move = { set_jumps = true },
            })

            local select = require("nvim-treesitter-textobjects.select")
            local move = require("nvim-treesitter-textobjects.move")
            local swap = require("nvim-treesitter-textobjects.swap")
            local rm = require("nvim-treesitter-textobjects.repeatable_move")
            local map = vim.keymap.set

            local function sel(lhs, query, desc)
                map({ "x", "o" }, lhs, function() select.select_textobject(query, "textobjects") end, { desc = desc })
            end
            sel("af", "@function.outer", "a function")
            sel("if", "@function.inner", "inner function")
            sel("ac", "@class.outer", "a class")
            sel("ic", "@class.inner", "inner class")
            sel("aa", "@parameter.outer", "a parameter")
            sel("ia", "@parameter.inner", "inner parameter")
            sel("ai", "@conditional.outer", "a conditional")
            sel("ii", "@conditional.inner", "inner conditional")
            sel("al", "@loop.outer", "a loop")
            sel("il", "@loop.inner", "inner loop")

            local function mv(lhs, fn, query, desc)
                map({ "n", "x", "o" }, lhs, function() fn(query, "textobjects") end, { desc = desc })
            end
            mv("]f", move.goto_next_start, "@function.outer", "Next function start")
            mv("[f", move.goto_previous_start, "@function.outer", "Prev function start")
            mv("]F", move.goto_next_end, "@function.outer", "Next function end")
            mv("[F", move.goto_previous_end, "@function.outer", "Prev function end")
            mv("]c", move.goto_next_start, "@class.outer", "Next class start")
            mv("[c", move.goto_previous_start, "@class.outer", "Prev class start")
            mv("]a", move.goto_next_start, "@parameter.inner", "Next parameter")
            mv("[a", move.goto_previous_start, "@parameter.inner", "Prev parameter")

            map("n", "<leader>sa", function() swap.swap_next("@parameter.inner") end, { desc = "Swap param right" })
            map("n", "<leader>sA", function() swap.swap_previous("@parameter.inner") end, { desc = "Swap param left" })

            -- ; と , で直前の ]f / [f などを繰り返す（f/t/F/T もそのまま使える）
            map({ "n", "x", "o" }, ";", rm.repeat_last_move_next, { desc = "Repeat last move" })
            map({ "n", "x", "o" }, ",", rm.repeat_last_move_previous, { desc = "Repeat last move (reverse)" })
            map({ "n", "x", "o" }, "f", rm.builtin_f_expr, { expr = true })
            map({ "n", "x", "o" }, "F", rm.builtin_F_expr, { expr = true })
            map({ "n", "x", "o" }, "t", rm.builtin_t_expr, { expr = true })
            map({ "n", "x", "o" }, "T", rm.builtin_T_expr, { expr = true })
        end,
    },
}
