-- Linting, narrowly scoped.
--
-- Most of the stack is already covered: eslint LSP handles JS/TS, clangd runs
-- clang-tidy internally, lua_ls diagnoses Lua, gopls does vet-level checks.
-- The genuine gaps are golangci-lint (far beyond gopls) and credo (elixirls
-- does no style analysis). Results report through vim.diagnostic, so the
-- existing virtual_lines styling applies automatically.
return {
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local lint = require("lint")
            lint.linters_by_ft = {
                go = { "golangcilint" },
                elixir = { "credo" },
                sh = { "shellcheck" },
                markdown = { "markdownlint" },
            }

            vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
                callback = function()
                    -- Only runs linters whose binary is actually on PATH.
                    require("lint").try_lint(nil, { ignore_errors = true })
                end,
            })
        end,
    },
}
