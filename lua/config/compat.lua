-- Compatibility shims for this Neovim build.
--
-- The installed nvim reports 0.12.0-dev and answers has("nvim-0.12") == 1, but
-- it predates several APIs that shipped with 0.12 proper. Plugins feature-detect
-- on the version string, get told "yes", and then call functions that aren't
-- there. Each shim below is self-disabling: it only installs itself if the real
-- API is genuinely missing, so upgrading Neovim silently retires them.
--
-- Absent on this build (checked): vim.text.diff, vim._core.ui2, 'pumborder',
-- 'busy'. Present: 'winborder', virtual_lines, foldtext = "".
--
-- The long-term fix is upgrading to a 0.12.x release; delete this file then.

-- ── vim.text.diff ────────────────────────────────────────────────────────
-- conform.nvim calls vim.text.diff() whenever has("nvim-0.12") is true, and
-- errors with "attempt to call field 'diff' (a nil value)" here -- which meant
-- formatting failed outright. vim.diff() is the older name for the same thing.
if vim.fn.has("nvim-0.12") == 1 and not (vim.text and vim.text.diff) then
    vim.text = vim.text or {}
    vim.text.diff = function(a, b, opts)
        return vim.diff(a, b, opts)
    end
end

-- ── vim.fs.root with nested marker groups ────────────────────────────────
-- nvim-lspconfig hands *nested* marker groups ({{...},{...}}) to lua_ls, jdtls,
-- emmylua_ls and ocamllsp on any build reporting nvim-0.11.3+. This build's
-- vim.fs.root only understands a flat list, so every file open raised
-- "invalid value (table) at index 2 in table for 'concat'" and no LSP server
-- ever attached. Flattening matches nvim-lspconfig's own pre-0.11.3 fallback.
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
