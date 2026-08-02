return {
    -- Mason: LSP/DAP/Linter/Formatter installer.
    -- Repos moved to the mason-org organisation; williamboman/* now only works
    -- via GitHub redirect. Also no longer eager -- mason-lspconfig pulls it in
    -- at BufReadPre anyway, so lazy=false just cost startup time.
    {
        "mason-org/mason.nvim",
        -- All of Mason's commands, not just :Mason -- lazy only registers the
        -- ones listed here, so `cmd = "Mason"` alone left :MasonInstall and
        -- friends undefined until the UI had been opened once.
        cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUninstallAll", "MasonLog", "MasonUpdate" },
        opts = {},
    },

    -- Lua development: adds library paths on demand based on what you actually
    -- require. Replaces `library = nvim_get_runtime_file("", true)`, which handed
    -- lua_ls all 48 plugin directories to recursively index.
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
        },
    },

    -- LSP configurations with Mason integration
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "mason-org/mason.nvim",
            "mason-org/mason-lspconfig.nvim",
        },
        config = function()
            -- The nested-root_markers shim that used to live here moved to
            -- lua/config/compat.lua, alongside the other build-version shims.

            -- ── Server configuration (Neovim 0.11+ vim.lsp.config API) ─────
            -- mason-lspconfig v2 removed the `handlers` option, so the old
            -- handler table silently never ran: no cmp capabilities, no
            -- per-server settings. Configure servers directly instead, then
            -- let mason-lspconfig enable whatever is installed.
            --
            -- Capabilities come from blink.cmp now (it also registers them via
            -- vim.lsp.config('*') itself; this is the explicit belt-and-braces form).
            local ok_blink, blink = pcall(require, "blink.cmp")
            vim.lsp.config("*", {
                capabilities = ok_blink and blink.get_lsp_capabilities({}, true) or nil,
                flags = { debounce_text_changes = 150 },
            })

            -- TypeScript: filter out noisy diagnostics
            vim.lsp.config("ts_ls", {
                handlers = {
                    ["textDocument/publishDiagnostics"] = function(_, result, ctx, cfg)
                        result.diagnostics = vim.tbl_filter(function(d)
                            return not d.message:match("Could not find a declaration file for module")
                                and not d.message:match("it may be converted to an ES module")
                        end, result.diagnostics)
                        vim.lsp.handlers["textDocument/publishDiagnostics"](_, result, ctx, cfg)
                    end,
                },
            })

            -- ESLint
            vim.lsp.config("eslint", {
                settings = {
                    codeAction = {
                        disableRuleComment = { enable = true, location = "separateLine" },
                        showDocumentation = { enable = true },
                    },
                },
            })

            -- Lua: lazydev.nvim supplies the library paths on demand, so this
            -- no longer hands lua_ls every runtime directory to index.
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            })

            -- Python: pyright for types/hover/completion, ruff for lint + fixes.
            -- Disable ruff's hover and pyright's import organising so the two
            -- don't both answer the same request.
            vim.lsp.config("ruff", {
                on_attach = function(client)
                    client.server_capabilities.hoverProvider = false
                end,
            })
            vim.lsp.config("pyright", {
                settings = {
                    pyright = { disableOrganizeImports = true },
                    python = { analysis = { typeCheckingMode = "standard" } },
                },
            })

            -- Elixir: let Mason supply the binary (it puts elixir-ls on PATH).
            -- The old hardcoded /usr/bin/elixir-ls does not exist on this box.
            vim.lsp.config("elixirls", {
                settings = {
                    elixirLS = { dialyzerEnabled = true, fetchDeps = false },
                },
            })

            -- Enable every installed server. Must run AFTER the vim.lsp.config
            -- calls above so the settings are registered before resolution.
            require("mason-lspconfig").setup({
                -- "ruff" is deliberately absent: Mason installs it into a pip
                -- venv, and this system's python3 has no ensurepip (needs
                -- `sudo apt install python3.10-venv`), so it would fail on every
                -- startup. It is installed user-level instead and enabled below.
                ensure_installed = {
                    "ts_ls", "eslint", "jsonls", "html", "cssls",
                    "pyright", "gopls", "jdtls", "lua_ls", "clangd",
                    "elixirls", "marksman",
                },
                automatic_enable = true,
            })

            -- ruff lives outside Mason (see above), so enable it by hand when
            -- the binary is present rather than letting it fail silently.
            if vim.fn.executable("ruff") == 1 then
                vim.lsp.enable("ruff")
            end

            -- LSP keybindings via LspAttach autocmd.
            --
            -- Neovim 0.11+ already binds grn (rename), gra (code action),
            -- grr (references), gri (implementation), grt (type definition),
            -- gO (document symbols), K (hover) and insert-mode <C-s>
            -- (signature help). The old config mapped bare `gr`, which is a
            -- *prefix* of four of those -- so every gr press stalled for the
            -- full timeoutlen (300ms) and grt was unreachable. It also mapped
            -- `gi`, destroying vanilla resume-insert-at-last-position.
            -- Only map what core does not provide.
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local bufnr = args.buf
                    local function buf_map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, noremap = true, silent = true, desc = desc })
                    end
                    buf_map("n", "gd", vim.lsp.buf.definition, "Go to definition")
                    buf_map("n", "gD", vim.lsp.buf.type_definition, "Go to type definition")

                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if not client then return end

                    -- Inlay hints: highest signal-per-pixel LSP feature for Go
                    -- and TypeScript, and off by default.
                    if client:supports_method("textDocument/inlayHint") then
                        pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
                        buf_map("n", "<leader>lh", function()
                            local on = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
                            vim.lsp.inlay_hint.enable(not on, { bufnr = bufnr })
                        end, "Toggle inlay hints")
                    end

                    -- ESLint auto-fix on save.
                    -- Runs as a synchronous code action rather than the async
                    -- :EslintFixAll command, so it completes before conform's
                    -- own BufWritePre handler formats the buffer. With the old
                    -- command form the two raced and dropped edits.
                    if client.name == "eslint" then
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            group = vim.api.nvim_create_augroup("eslint_fix_" .. bufnr, { clear = true }),
                            buffer = bufnr,
                            callback = function()
                                pcall(vim.lsp.buf.code_action, {
                                    context = { only = { "source.fixAll.eslint" }, diagnostics = {} },
                                    apply = true,
                                })
                            end,
                        })
                    end
                end,
            })
        end,
    },

    -- Code outline / symbol navigation
    {
        "stevearc/aerial.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        cmd = { "AerialToggle", "AerialOpen" },
        keys = {
            { "<leader>co", "<cmd>AerialToggle!<CR>", desc = "Toggle code outline" },
        },
        config = function()
            require("aerial").setup({
                backends = { "lsp", "treesitter", "markdown" },
                layout = { default_direction = "prefer_right", min_width = 30 },
                manage_folds = true,
                highlight_closest = true,
                nerd_font = "auto",
                attach_mode = "global",
                keymaps = {
                    ["<CR>"] = "actions.jump",
                    ["<2-LeftMouse>"] = "actions.jump",
                    ["{"] = "actions.prev",
                    ["}"] = "actions.next",
                    ["[["] = "actions.prev_up",
                    ["]]"] = "actions.next_up",
                    ["<C-j>"] = "actions.down_and_scroll",
                    ["<C-k>"] = "actions.up_and_scroll",
                },
            })
        end,
    },
}
