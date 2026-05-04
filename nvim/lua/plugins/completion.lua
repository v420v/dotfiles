-- ─── Completion ── nvim-cmp + LuaSnip ────────────────────────
return {
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "saadparwaiz1/cmp_luasnip",
            {
                "L3MON4D3/LuaSnip",
                version = "v2.*",
                dependencies = { "rafamadriz/friendly-snippets" },
                build = nil,                                   -- skip jsregexp on NixOS
                config = function()
                    require("luasnip.loaders.from_vscode").lazy_load()
                end,
            },
        },
        config = function()
            local cmp    = require("cmp")
            local luasnip = require("luasnip")

            local kind_icons = {
                Text = "", Method = "󰆧", Function = "󰊕", Constructor = "",
                Field = "󰜢", Variable = "󰀫", Class = "󰠱", Interface = "",
                Module = "", Property = "󰜢", Unit = "󰑭", Value = "󰎠",
                Enum = "", Keyword = "󰌋", Snippet = "", Color = "󰏘",
                File = "󰈙", Reference = "󰈇", Folder = "󰉋", EnumMember = "",
                Constant = "󰏿", Struct = "󰙅", Event = "", Operator = "󰆕",
                TypeParameter = "",
            }

            cmp.setup({
                snippet = {
                    expand = function(args) luasnip.lsp_expand(args.body) end,
                },
                window = {
                    completion    = cmp.config.window.bordered({ border = "rounded" }),
                    documentation = cmp.config.window.bordered({ border = "rounded" }),
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"]     = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"]     = cmp.mapping.abort(),
                    ["<CR>"]      = cmp.mapping.confirm({ select = false }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
                        else fallback() end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then luasnip.jump(-1)
                        else fallback() end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp", priority = 1000 },
                    { name = "luasnip",  priority = 750 },
                    { name = "path",     priority = 500 },
                }, {
                    { name = "buffer", priority = 250, keyword_length = 3 },
                }),
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = function(entry, item)
                        item.kind = string.format("%s ", kind_icons[item.kind] or "")
                        item.menu = ({
                            nvim_lsp = "[LSP]",
                            luasnip  = "[Snip]",
                            buffer   = "[Buf]",
                            path     = "[Path]",
                        })[entry.source.name]
                        return item
                    end,
                },
                experimental = { ghost_text = true },
            })

            -- `/` & `?` use buffer source for in-file search completion.
            cmp.setup.cmdline({ "/", "?" }, {
                mapping = cmp.mapping.preset.cmdline(),
                sources = { { name = "buffer" } },
            })
            -- `:` completes paths + commands.
            cmp.setup.cmdline(":", {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources(
                    { { name = "path" } },
                    { { name = "cmdline" } }
                ),
            })
        end,
    },
}
