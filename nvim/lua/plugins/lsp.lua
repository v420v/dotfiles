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
                    map("n", "<leader>ls", vim.lsp.buf.signature_help,  "Signature help")
                    map("n", "<leader>rn", vim.lsp.buf.rename,          "Rename symbol")
                    map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, "Code action")
                    map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic")
                    map("n", "]d", function() vim.diagnostic.jump({ count =  1, float = true }) end, "Next diagnostic")
                    map("n", "<leader>ld", vim.diagnostic.open_float,   "Show diagnostic")
                    map("n", "<leader>cl", "<cmd>LspInfo<CR>",          "LSP info")

                    -- Auto-hover: when the cursor rests on a symbol (updatetime
                    -- = 250ms), pop up its definition info without pressing K.
                    -- focusable = false keeps the cursor in the buffer; the
                    -- float closes itself the moment you move on. Toggle off
                    -- per-buffer with :let b:disable_autohover = 1.
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client:supports_method("textDocument/hover") then
                        vim.api.nvim_create_autocmd("CursorHold", {
                            buffer = args.buf,
                            callback = function()
                                if vim.b.disable_autohover then return end
                                vim.lsp.buf.hover({ focusable = false })
                            end,
                        })
                    end
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
                intelephense = {                -- PHP / Laravel
                    -- Sensible Laravel defaults: bump the per-file size cap
                    -- (Laravel ships big generated files like the IDE helper)
                    -- and surface Blade files to the server too. Facade/magic-
                    -- method resolution still wants `barryvdh/laravel-ide-helper`
                    -- run in the project (generates _ide_helper.php) — that's
                    -- project-side, not editor config.
                    settings = {
                        intelephense = {
                            files       = { maxSize = 5000000 },
                            environment = { phpVersion = "8.3" },
                        },
                    },
                },
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
                v_analyzer = {},               -- V (binary: `v-analyzer`)
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

            -- Apply our cmp capabilities to every server (0.11 API).
            vim.lsp.config("*", { capabilities = capabilities })

            for name, cfg in pairs(servers) do
                vim.lsp.config(name, cfg)
            end
            vim.lsp.enable(vim.tbl_keys(servers))
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
                function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
                mode = { "n", "v" },
                desc = "Format buffer",
            },
        },
        -- opts is a function so `require("conform.util")` below is deferred
        -- until conform.nvim is on the runtimepath (it isn't yet when lazy.nvim
        -- first reads this spec).
        opts = function() return {
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
                -- Prefer the project's own Laravel Pint (./vendor/bin/pint, see
                -- the formatter override below); fall back to the system
                -- php-cs-fixer when a project doesn't vendor Pint.
                php           = { "pint", "php_cs_fixer", stop_after_first = true },
                v             = { "v_fmt" },
            },
            formatters = {
                -- Pint isn't packaged standalone, so resolve it from the
                -- project's composer vendor dir, falling back to a `pint` on
                -- PATH if one happens to be installed globally.
                pint = {
                    command = require("conform.util").find_executable(
                        { "vendor/bin/pint" }, "pint"),
                },
                -- `v fmt` rewrites the file in place rather than streaming to
                -- stdout, so point conform at the buffer's path and skip stdin.
                v_fmt = {
                    command = "v",
                    args    = { "fmt", "-w", "$FILENAME" },
                    stdin   = false,
                },
            },
            format_on_save = function(bufnr)
                -- Disable with :FormatDisable on a buffer or globally.
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
                return { timeout_ms = 1500, lsp_format = "fallback" }
            end,
        } end,
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
