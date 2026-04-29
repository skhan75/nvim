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
            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local default_opts = {
                capabilities = capabilities,
                flags = { debounce_text_changes = 150 },
            }

            -- Mason-lspconfig bridge: auto-install servers and set them up via handlers
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "ts_ls", "eslint", "jsonls", "html", "cssls",
                    "pyright", "gopls", "jdtls", "lua_ls", "clangd",
                    "elixirls", "marksman",
                },
                automatic_installation = true,
                handlers = {
                    -- Default handler: setup every server with shared capabilities
                    function(server_name)
                        lspconfig[server_name].setup(default_opts)
                    end,

                    -- TypeScript: filter out noisy diagnostics
                    ["ts_ls"] = function()
                        lspconfig.ts_ls.setup(vim.tbl_deep_extend("force", default_opts, {
                            handlers = {
                                ["textDocument/publishDiagnostics"] = function(_, result, ctx, cfg)
                                    result.diagnostics = vim.tbl_filter(function(d)
                                        return not d.message:match("Could not find a declaration file for module")
                                            and not d.message:match("it may be converted to an ES module")
                                    end, result.diagnostics)
                                    vim.lsp.handlers["textDocument/publishDiagnostics"](_, result, ctx, cfg)
                                end,
                            },
                        }))
                    end,

                    -- ESLint
                    ["eslint"] = function()
                        lspconfig.eslint.setup(vim.tbl_deep_extend("force", default_opts, {
                            settings = {
                                codeAction = {
                                    disableRuleComment = { enable = true, location = "separateLine" },
                                    showDocumentation = { enable = true },
                                },
                            },
                        }))
                    end,

                    -- Lua: Neovim development settings
                    ["lua_ls"] = function()
                        lspconfig.lua_ls.setup(vim.tbl_deep_extend("force", default_opts, {
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
                        }))
                    end,

                    -- Elixir: OS-specific language server path
                    ["elixirls"] = function()
                        local opts = vim.tbl_deep_extend("force", default_opts, {
                            settings = {
                                elixirLS = { dialyzerEnabled = true, fetchDeps = false },
                            },
                        })
                        if vim.fn.has("mac") == 1 then
                            opts.cmd = { "/opt/homebrew/bin/elixir-ls" }
                        elseif vim.fn.has("unix") == 1 then
                            opts.cmd = { "/usr/bin/elixir-ls" }
                        end
                        lspconfig.elixirls.setup(opts)
                    end,
                },
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
