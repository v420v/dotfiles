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
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                            ["aa"] = "@parameter.outer",
                            ["ia"] = "@parameter.inner",
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
                        goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
                    },
                },
            })
        end,
    },
}
