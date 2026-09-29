return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            { "j-hui/fidget.nvim", opts = {} },
        },
        config = function()
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            vim.diagnostic.config({
                virtual_text = { spacing = 4, prefix = "●" },
                severity_sort = true,
                update_in_insert = false,
                float = { border = "rounded", source = "if_many" },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "",
                        [vim.diagnostic.severity.WARN] = "",
                        [vim.diagnostic.severity.INFO] = "",
                        [vim.diagnostic.severity.HINT] = "",
                    },
                },
            })

            vim.o.winborder = "rounded"

            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
                callback = function(args)
                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
                    end
                    map("n", "gd", vim.lsp.buf.definition, "Go to definition")
                    map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
                    map("n", "gr", vim.lsp.buf.references, "References")
                    map("n", "gi", vim.lsp.buf.implementation, "Implementation")
                    map("n", "gt", vim.lsp.buf.type_definition, "Type definition")
                    map("n", "K", vim.lsp.buf.hover, "Hover")
                    map("n", "<leader>ls", vim.lsp.buf.signature_help, "Signature help")
                    map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
                    map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, "Code action")
                    map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
                    map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")
                    map("n", "<leader>ld", vim.diagnostic.open_float, "Show diagnostic")
                    map("n", "<leader>cl", "<cmd>LspInfo<CR>", "LSP info")

                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client:supports_method("textDocument/hover") then
                        vim.api.nvim_create_autocmd("CursorHold", {
                            group = vim.api.nvim_create_augroup("UserLspHover" .. args.buf, { clear = true }),
                            buffer = args.buf,
                            callback = function()
                                if vim.b.disable_autohover then return end
                                vim.lsp.buf.hover({ focusable = false })
                            end,
                        })
                    end
                end,
            })

            local function vue_language_server_path()
                local bin = vim.fn.exepath("vue-language-server")
                if bin == "" then return nil end
                local store = (vim.uv.fs_realpath(bin) or bin):match("^(/nix/store/[^/]+)")
                if not store then return nil end
                local hits = vim.fn.glob(store .. "/lib/node_modules/@vue/language-server", true, true)
                return hits[1]
            end
            local vue_ls_path = vue_language_server_path()

            local servers = {
                gopls = {
                    settings = {
                        gopls = {
                            analyses = { unusedparams = true, shadow = true },
                            staticcheck = true,
                            gofumpt = true,
                        },
                    },
                },
                ts_ls = {
                    filetypes = {
                        "javascript",
                        "javascriptreact",
                        "typescript",
                        "typescriptreact",
                        "vue",
                    },
                    init_options = vue_ls_path and {
                        plugins = {
                            {
                                name = "@vue/typescript-plugin",
                                location = vue_ls_path,
                                languages = { "vue" },
                            },
                        },
                    } or nil,
                },
                vue_ls = {},
                html = {},
                cssls = {},
                jsonls = {},
                eslint = {},
                intelephense = {
                    filetypes = { "php", "blade" },
                    settings = {
                        intelephense = {
                            files = {
                                maxSize = 5000000,
                                associations = { "*.php", "*.blade.php" },
                            },
                            environment = { phpVersion = "8.3" },
                        },
                    },
                },
                clangd = {
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--header-insertion=iwyu",
                        "--completion-style=detailed",
                        "--function-arg-placeholders",
                    },
                },
                asm_lsp = {},
                bashls = {},
                nil_ls = {},
                lua_ls = {
                    settings = {
                        Lua = {
                            runtime = { version = "LuaJIT" },
                            workspace = {
                                checkThirdParty = false,
                                library = vim.api.nvim_get_runtime_file("", true),
                            },
                            diagnostics = { globals = { "vim" } },
                            telemetry = { enable = false },
                        },
                    },
                },
            }

            vim.lsp.config("*", { capabilities = capabilities })

            for name, cfg in pairs(servers) do
                vim.lsp.config(name, cfg)
            end
            vim.lsp.enable(vim.tbl_keys(servers))
        end,
    },

    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                "<leader>cf",
                function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
                mode = { "n", "v" },
                desc = "Format buffer",
            },
        },
        opts = function()
            return {
                formatters_by_ft = {
                    go = { "gofumpt", "goimports" },
                    javascript = { "prettierd", "prettier", stop_after_first = true },
                    typescript = { "prettierd", "prettier", stop_after_first = true },
                    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
                    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
                    vue = { "prettierd", "prettier", stop_after_first = true },
                    html = { "prettierd", "prettier", stop_after_first = true },
                    css = { "prettierd", "prettier", stop_after_first = true },
                    scss = { "prettierd", "prettier", stop_after_first = true },
                    json = { "prettierd", "prettier", stop_after_first = true },
                    yaml = { "prettierd", "prettier", stop_after_first = true },
                    markdown = { "prettierd", "prettier", stop_after_first = true },
                    c = { "clang_format" },
                    cpp = { "clang_format" },
                    lua = { "stylua" },
                    nix = { "nixpkgs_fmt" },
                    sh = { "shfmt" },
                    php = { "pint", "php_cs_fixer", stop_after_first = true },
                    v = { "v_fmt" },
                },
                formatters = {
                    pint = {
                        command = require("conform.util").find_executable({ "vendor/bin/pint" }, "pint"),
                    },
                    v_fmt = {
                        command = "v",
                        args = { "fmt", "-w", "$FILENAME" },
                        stdin = false,
                    },
                },
                format_on_save = function(bufnr)
                    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
                    return { timeout_ms = 1500, lsp_format = "fallback" }
                end,
            }
        end,
        init = function()
            vim.g.disable_autoformat = true
            vim.api.nvim_create_user_command("FormatDisable", function(args)
                if args.bang then
                    vim.b.disable_autoformat = true
                else
                    vim.g.disable_autoformat = true
                end
            end, { bang = true, desc = "Disable autoformat (! = buffer only)" })
            vim.api.nvim_create_user_command("FormatEnable", function()
                vim.b.disable_autoformat, vim.g.disable_autoformat = false, false
            end, { desc = "Re-enable autoformat" })
        end,
    },
}
