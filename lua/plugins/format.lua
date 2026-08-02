-- Formatting. The config previously had none at all: no conform, no null-ls,
-- no format keymap, no vim.lsp.buf.format call anywhere. The only auto-format
-- was EslintFixAll on save for JS/TS, leaving Python, Go, Lua, JSON, YAML,
-- Markdown, C/C++ and Java entirely unformatted.
--
-- lsp_format = "fallback" means the external formatter wins and the LSP only
-- fills gaps (gopls, jdtls, lua_ls, elixirls).
return {
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        cmd = "ConformInfo",
        keys = {
            {
                "<leader>cf",
                function()
                    require("conform").format({ async = true, lsp_format = "fallback" })
                end,
                mode = { "n", "v" },
                desc = "Format buffer/range",
            },
        },
        opts = {
            formatters_by_ft = {
                lua = { "stylua" },
                python = { "ruff_fix", "ruff_format" },
                go = { "goimports", "gofumpt" },
                elixir = { "mix" },
                javascript = { "prettierd", "prettier", stop_after_first = true },
                javascriptreact = { "prettierd", "prettier", stop_after_first = true },
                typescript = { "prettierd", "prettier", stop_after_first = true },
                typescriptreact = { "prettierd", "prettier", stop_after_first = true },
                json = { "prettierd", "prettier", stop_after_first = true },
                jsonc = { "prettierd", "prettier", stop_after_first = true },
                html = { "prettierd", "prettier", stop_after_first = true },
                css = { "prettierd", "prettier", stop_after_first = true },
                scss = { "prettierd", "prettier", stop_after_first = true },
                yaml = { "prettierd", "prettier", stop_after_first = true },
                markdown = { "prettierd", "prettier", stop_after_first = true },
                c = { "clang-format" },
                cpp = { "clang-format" },
                sh = { "shfmt" },
                ["_"] = { "trim_whitespace" },
            },
            default_format_opts = { lsp_format = "fallback" },
            format_on_save = function(bufnr)
                if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
                    return
                end
                -- Don't block the write on very large files.
                local name = vim.api.nvim_buf_get_name(bufnr)
                local ok, stat = pcall((vim.uv or vim.loop).fs_stat, name)
                if ok and stat and stat.size > 200 * 1024 then
                    return
                end
                return { timeout_ms = 1000, lsp_format = "fallback" }
            end,
        },
        init = function()
            -- Make gq use conform too.
            vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
            vim.api.nvim_create_user_command("FormatToggle", function(a)
                if a.bang then
                    vim.b.disable_autoformat = not vim.b.disable_autoformat
                else
                    vim.g.disable_autoformat = not vim.g.disable_autoformat
                end
            end, { bang = true, desc = "Toggle format-on-save (! = buffer only)" })
        end,
    },
}
