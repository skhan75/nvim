return {
    -- Mason: LSP/DAP/Linter/Formatter installer
    {
        "williamboman/mason.nvim",
        lazy = false,
        config = function()
            require("mason").setup()
        end,
    },

    -- LSP configurations with Mason integration
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            -- ── Compat: nested root_marker groups ──────────────────────────
            -- nvim-lspconfig feeds *nested* marker groups ({{...},{...}}) to
            -- lua_ls / jdtls / emmylua_ls / ocamllsp on any build reporting
            -- nvim-0.11.3+. Some 0.12-dev builds report that yet ship a
            -- vim.fs.root which only understands a flat list, so every file
            -- open raised "invalid value (table) at index 2 ... for 'concat'"
            -- and no server ever attached. Flatten on affected builds only --
            -- this mirrors nvim-lspconfig's own pre-0.11.3 fallback.
            if not pcall(vim.fs.root, (vim.uv or vim.loop).cwd(), { { ".git" } }) then
                local orig_root = vim.fs.root
                vim.fs.root = function(source, marker)
                    if type(marker) == "table" then
                        local flat, nested = {}, false
                        for _, group in ipairs(marker) do
                            if type(group) == "table" then
                                nested = true
                                for _, m in ipairs(group) do
                                    flat[#flat + 1] = m
                                end
                            else
                                flat[#flat + 1] = group
                            end
                        end
                        if nested then
                            marker = flat
                        end
                    end
                    return orig_root(source, marker)
                end
            end

            -- ── Server configuration (Neovim 0.11+ vim.lsp.config API) ─────
            -- mason-lspconfig v2 removed the `handlers` option, so the old
            -- handler table silently never ran: no cmp capabilities, no
            -- per-server settings. Configure servers directly instead, then
            -- let mason-lspconfig enable whatever is installed.
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            vim.lsp.config("*", {
                capabilities = capabilities,
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

            -- Lua: Neovim development settings
            vim.lsp.config("lua_ls", {
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT" },
                        diagnostics = { globals = { "vim" } },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file("", true),
                            checkThirdParty = false,
                        },
                        telemetry = { enable = false },
                    },
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
                ensure_installed = {
                    "ts_ls", "eslint", "jsonls", "html", "cssls",
                    "pyright", "gopls", "jdtls", "lua_ls", "clangd",
                    "elixirls", "marksman",
                },
                automatic_enable = true,
            })

            -- LSP keybindings via LspAttach autocmd
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local bufnr = args.buf
                    local function buf_map(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, noremap = true, silent = true, desc = desc })
                    end
                    buf_map("n", "gd", vim.lsp.buf.definition, "Go to definition")
                    buf_map("n", "gr", vim.lsp.buf.references, "Show references")
                    buf_map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
                    buf_map("n", "gk", vim.lsp.buf.hover, "Hover documentation")
                    buf_map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
                    buf_map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
                    buf_map("n", "<leader>ca", vim.lsp.buf.code_action, "Code actions")

                    -- ESLint: auto-fix on save
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client.name == "eslint" then
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            buffer = bufnr,
                            command = "EslintFixAll",
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
