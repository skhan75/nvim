-- Completion: blink.cmp, replacing nvim-cmp + its six source plugins.
--
-- Why: nvim-cmp debounces updates by 60ms and its README describes itself as a
-- hobby project the author may not fix. blink resolves in ~0.5-4ms with a SIMD
-- fuzzy matcher that tolerates typos, and ships LSP/path/snippet/buffer/cmdline
-- /signature support in one spec. That matters most in TypeScript and Java,
-- where completion lists are largest.
--
-- Pinned to v1: v2 is under active development, has no stable release, and
-- requires a separate blink.lib install.
return {
    {
        "saghen/blink.cmp",
        version = "1.*",
        -- Deliberately NOT lazy-loaded. blink registers its completion
        -- capabilities through vim.lsp.config('*'), which must happen before
        -- nvim-lspconfig starts servers at BufReadPre. It costs ~1ms.
        lazy = false,
        dependencies = {
            { "L3MON4D3/LuaSnip", version = "v2.*", dependencies = { "rafamadriz/friendly-snippets" } },
        },
        opts = {
            -- friendly-snippets is a VSCode-format corpus LuaSnip loads natively,
            -- so keep LuaSnip rather than switching to vim.snippet.
            snippets = { preset = "luasnip" },

            keymap = {
                preset = "enter", -- <CR> accepts, <C-y> also accepts
                ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<C-e>"] = { "hide", "fallback" },
                ["<C-b>"] = { "scroll_documentation_up", "fallback" },
                ["<C-f>"] = { "scroll_documentation_down", "fallback" },
                -- Mirrors the previous nvim-cmp Tab semantics: snippet jump
                -- wins, then menu navigation, then a literal Tab.
                ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
                ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
            },

            appearance = { nerd_font_variant = "mono" },

            completion = {
                accept = { auto_brackets = { enabled = true } },
                documentation = { auto_show = true, auto_show_delay_ms = 200 },
                ghost_text = { enabled = false },
                list = { selection = { preselect = true, auto_insert = false } },
                menu = { border = "rounded" },
            },

            -- nvim-cmp had no signature help at all; this replaces the
            -- normal-mode <C-k> mapping that was shadowing window navigation.
            signature = { enabled = true, window = { border = "rounded" } },

            cmdline = {
                enabled = true,
                keymap = { preset = "cmdline" },
                completion = { menu = { auto_show = true } },
            },

            sources = {
                default = { "lazydev", "lsp", "path", "snippets", "buffer" },
                providers = {
                    -- lazydev knows the Neovim API surface for the modules this
                    -- config actually requires; rank it above plain LSP items.
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        score_offset = 100,
                    },
                    snippets = { opts = { friendly_snippets = true } },
                },
            },

            -- Falls back to the Lua matcher with a warning if the prebuilt Rust
            -- binary can't be fetched, rather than failing hard.
            fuzzy = { implementation = "prefer_rust_with_warning" },
        },
        opts_extend = { "sources.default" },
    },
}
