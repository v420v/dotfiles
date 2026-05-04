-- ─── LSP ─────────────────────────────────────────────────────
-- We rely on system-installed language servers (managed by NixOS),
-- not Mason — Mason downloads dynamically-linked binaries that don't
-- run on Nix. Make sure the servers below are in configuration.nix.
return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            { "j-hui/fidget.nvim", opts = {} },     -- LSP progress UI
        },
        config = function()
            local lspconfig    = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- Diagnostics presentation
            vim.diagnostic.config({
                virtual_text     = { spacing = 4, prefix = "●" },
                severity_sort    = true,
                update_in_insert = false,
                float            = { border = "rounded", source = "if_many" },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = "",
                        [vim.diagnostic.severity.WARN]  = "",
                        [vim.diagnostic.severity.INFO]  = "",
                        [vim.diagnostic.severity.HINT]  = "",
                    },
                },
            })

            -- Rounded borders for every floating window (0.11+ API).
            vim.o.winborder = "rounded"

            -- Buffer-local keymaps wired up the moment a server attaches.
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
                callback = function(args)
                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
                    end
                    map("n", "gd",         vim.lsp.buf.definition,      "Go to definition")
                    map("n", "gD",         vim.lsp.buf.declaration,     "Go to declaration")
                    map("n", "gr",         vim.lsp.buf.references,      "References")
                    map("n", "gi",         vim.lsp.buf.implementation,  "Implementation")
                    map("n", "gt",         vim.lsp.buf.type_definition, "Type definition")
                    map("n", "K",          vim.lsp.buf.hover,           "Hover")
                    map("n", "<C-k>",      vim.lsp.buf.signature_help,  "Signature help")
                    map("n", "<leader>rn", vim.lsp.buf.rename,          "Rename symbol")
                    map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
                    map("n", "[d",         vim.diagnostic.goto_prev,    "Prev diagnostic")
                    map("n", "]d",         vim.diagnostic.goto_next,    "Next diagnostic")
                    map("n", "<leader>cd", vim.diagnostic.open_float,   "Show diagnostic")
                    map("n", "<leader>cl", "<cmd>LspInfo<CR>",          "LSP info")
                end,
            })

            -- Per-server overrides (everything else uses defaults).
            local servers = {
                gopls = {
                    settings = {
                        gopls = {
                            analyses = { unusedparams = true, shadow = true },
                            staticcheck = true,
                            gofumpt     = true,
                        },
                    },
                },
                ts_ls    = {},                  -- typescript-language-server
                html     = {},
                cssls    = {},
                jsonls   = {},
                eslint   = {},
                clangd   = {                   -- C / C++ / Objective-C
                    cmd = {
                        "clangd",
                        "--background-index",
                        "--clang-tidy",
                        "--header-insertion=iwyu",
                        "--completion-style=detailed",
                        "--function-arg-placeholders",
                    },
                },
                asm_lsp  = {},                 -- Assembly (x86 / ARM / RISC-V intrinsics)
                bashls   = {},
                nil_ls   = {},                 -- Nix
                lua_ls   = {
                    settings = {
                        Lua = {
                            runtime     = { version = "LuaJIT" },
                            workspace   = {
                                checkThirdParty = false,
                                library = vim.api.nvim_get_runtime_file("", true),
                            },
                            diagnostics = { globals = { "vim" } },
                            telemetry   = { enable = false },
                        },
                    },
                },
            }

            for name, cfg in pairs(servers) do
                cfg.capabilities = vim.tbl_deep_extend(
                    "force", {}, capabilities, cfg.capabilities or {}
                )
                lspconfig[name].setup(cfg)
            end
        end,
    },

    -- ─── Formatting ──────────────────────────────────────────
    -- conform.nvim drives system-installed formatters: gofmt, prettierd,
    -- clang-format, stylua. Format on save, fall back to LSP otherwise.
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd   = { "ConformInfo" },
        keys  = {
            {
                "<leader>cf",
                function() require("conform").format({ async = true, lsp_fallback = true }) end,
                mode = { "n", "v" },
                desc = "Format buffer",
            },
        },
        opts = {
            formatters_by_ft = {
                go            = { "gofumpt", "goimports" },
                javascript    = { "prettierd", "prettier", stop_after_first = true },
                typescript    = { "prettierd", "prettier", stop_after_first = true },
                javascriptreact = { "prettierd", "prettier", stop_after_first = true },
                typescriptreact = { "prettierd", "prettier", stop_after_first = true },
                html          = { "prettierd", "prettier", stop_after_first = true },
                css           = { "prettierd", "prettier", stop_after_first = true },
                scss          = { "prettierd", "prettier", stop_after_first = true },
                json          = { "prettierd", "prettier", stop_after_first = true },
                yaml          = { "prettierd", "prettier", stop_after_first = true },
                markdown      = { "prettierd", "prettier", stop_after_first = true },
                c             = { "clang_format" },
                cpp           = { "clang_format" },
                lua           = { "stylua" },
                nix           = { "nixpkgs_fmt" },
                sh            = { "shfmt" },
            },
            format_on_save = function(bufnr)
                -- Disable with :FormatDisable on a buffer or globally.
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
                return { timeout_ms = 1500, lsp_fallback = true }
            end,
        },
        init = function()
            vim.api.nvim_create_user_command("FormatDisable", function(args)
                if args.bang then vim.b.disable_autoformat = true
                else vim.g.disable_autoformat = true end
            end, { bang = true, desc = "Disable autoformat (! = buffer only)" })
            vim.api.nvim_create_user_command("FormatEnable", function()
                vim.b.disable_autoformat, vim.g.disable_autoformat = false, false
            end, { desc = "Re-enable autoformat" })
        end,
    },
}
