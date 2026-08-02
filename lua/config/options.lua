local opt = vim.opt
local indent = 4

-- Disable unused language providers to silence :checkhealth warnings
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Ensure tree-sitter CLI and local binaries are discoverable
local home = os.getenv("HOME") or ""
local extra_paths = {
    home .. "/.npm-global/bin",
    home .. "/.local/bin",
}
local current_path = vim.env.PATH or ""
for i = #extra_paths, 1, -1 do
    if not current_path:find(extra_paths[i], 1, true) then
        vim.env.PATH = extra_paths[i] .. ":" .. current_path
        current_path = vim.env.PATH
    end
end

-- General
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.swapfile = false
opt.completeopt = "menuone,noselect"
-- 'ruler' omitted: laststatus=3 means it never renders.
opt.laststatus = 3
opt.incsearch = true
opt.showmatch = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.conceallevel = 0
opt.undofile = true
opt.timeoutlen = 300
opt.ttimeoutlen = 10

-- Indentation
opt.tabstop = indent
opt.shiftwidth = indent
opt.softtabstop = indent
opt.expandtab = true
opt.smartindent = true

-- UI
opt.number = true
opt.relativenumber = true
opt.colorcolumn = "80"
-- Fixed-width gutter: with "auto" the whole buffer shifts sideways the moment
-- a diagnostic or git sign appears, then shifts back.
opt.signcolumn = "yes:1"
-- One consistent border for every float (hover, signature, diagnostics, input).
opt.winborder = "rounded"

-- Folding via treesitter. Was "marker", which meant folds only existed where
-- someone typed {{{ -- i.e. nowhere -- despite a full parser set being installed.
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = "" -- 0.10+: render the fold's first line with real highlighting
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldnestmax = 4
opt.cmdheight = 1
opt.splitright = true
opt.splitbelow = true
opt.cursorline = true
opt.ignorecase = true
opt.smartcase = true
opt.linebreak = true
opt.termguicolors = true
opt.wrap = true
opt.background = "dark"

-- Performance
opt.hidden = true
opt.history = 100
opt.updatetime = 200
-- synmaxcol removed: it capped the *regex* syntax engine, which treesitter
-- highlighting (started in plugins/editor.lua) now replaces entirely.

-- Navigation
-- "stack" keeps the jumplist sane when you branch; "view" restores the exact
-- scroll position on <C-o>. Together they make jumping cheap enough to do freely.
opt.jumpoptions = "stack,view"

-- Misc
opt.shortmess:append("c")
opt.whichwrap:append("<,>,[,],h,l")
opt.iskeyword:append("-")
opt.belloff = "all"
-- Search highlighting is on (it was off, which makes search useless as a motion);
-- <Esc> clears it -- see config/keymaps.lua.
opt.hlsearch = true

-- Format options
opt.formatoptions = opt.formatoptions
    + "c" -- Comments respect textwidth
    + "q" -- Allow formatting comments w/ gq
    - "o" -- O and o don't continue comments
    - "r" -- Don't insert comment after <Enter>
    + "n" -- Indent past the formatlistpat, not underneath it

-- Markdown fenced language highlighting
vim.g.vim_markdown_fenced_languages = {
    "html", "javascript", "typescript", "css", "python", "lua", "vim",
}

-- Window separators (clean thin line)
opt.fillchars = {
    horiz = "─",
    horizup = "┴",
    horizdown = "┬",
    vert = "│",
    vertleft = "┤",
    vertright = "├",
    verthoriz = "┼",
    eob = " ",
}

-- Diagnostics:
--   Cursor line  → full wrapping message via virtual_lines (no overflow)
--   Other lines  → gutter sign only (clean, no clutter)
-- Toggle to see all virtual_lines at once with <leader>lL (defined below).
vim.diagnostic.config({
    virtual_lines = { current_line = true },
    virtual_text = false,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.HINT]  = "󰌵 ",
            [vim.diagnostic.severity.INFO]  = " ",
        },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        border = "rounded",
        source = true,
        header = "",
        prefix = "",
        max_width = 80,
        wrap = true,
    },
})

-- Toggle full virtual_lines (all lines) vs current-line-only
vim.keymap.set("n", "<leader>lL", function()
    local cfg = vim.diagnostic.config() or {}
    local vl = cfg.virtual_lines
    if type(vl) == "table" and vl.current_line then
        vim.diagnostic.config({ virtual_lines = true })
        vim.notify("Diagnostics: virtual_lines (all)", vim.log.levels.INFO)
    else
        vim.diagnostic.config({ virtual_lines = { current_line = true } })
        vim.notify("Diagnostics: current line only", vim.log.levels.INFO)
    end
end, { desc = "Toggle diagnostic display mode" })

-- Floating popup with full diagnostic for the current line
vim.keymap.set("n", "<leader>le", function()
    vim.diagnostic.open_float(nil, { scope = "line" })
end, { desc = "Show diagnostics for current line" })

-- nvim-tree calls sign_place with these names but only defines them when
-- renderer.icons.show.diagnostics is true. Register them ourselves so
-- sign_place never fails. Also re-apply after lazy loads in case nvim-tree
-- undefined them during its own setup.
local function define_nvim_tree_signs()
    vim.fn.sign_define("NvimTreeDiagnosticErrorIcon", { text = "", texthl = "DiagnosticError" })
    vim.fn.sign_define("NvimTreeDiagnosticWarnIcon",  { text = "", texthl = "DiagnosticWarn" })
    vim.fn.sign_define("NvimTreeDiagnosticInfoIcon",  { text = "", texthl = "DiagnosticInfo" })
    vim.fn.sign_define("NvimTreeDiagnosticHintIcon",  { text = "󰌵", texthl = "DiagnosticHint" })
end
define_nvim_tree_signs()
vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    callback = define_nvim_tree_signs,
})

-- Highlight on yank (built-in, no plugin needed).
-- Uses a dedicated group, not IncSearch -- IncSearch is dark-on-#66FFFF, which
-- strobes the whole line on every yank.
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
        vim.hl.on_yank({ higroup = "YankFlash", timeout = 150 })
    end,
})

-- Prose settings. Replaces vim-pencil, which was unmaintained since 2023 and
-- whose "soft wrap" mode is just these five options.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("prose", { clear = true }),
    pattern = { "markdown", "gitcommit", "text" },
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.breakindent = true
        vim.opt_local.spell = true
        vim.opt_local.colorcolumn = ""
        -- render-markdown.nvim needs conceal to hide **, _, [](). The global
        -- conceallevel=0 was silently defeating it.
        vim.opt_local.conceallevel = 3
        vim.opt_local.concealcursor = ""
    end,
})

-- WSL clipboard integration
if vim.fn.has("wsl") == 1 then
    -- executable() alone is enough to detect WSL interop. The previous check
    -- also ran clip.exe through vim.fn.system() on every startup, which
    -- spawns a Windows process synchronously and cost ~40ms per launch for
    -- information executable() already gives us for free.
    if vim.fn.executable("clip.exe") == 1 then
        vim.g.clipboard = {
            name = "WslClipboard",
            copy = {
                ["+"] = "clip.exe",
                ["*"] = "clip.exe",
            },
            paste = {
                ["+"] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
                ["*"] = 'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            },
            cache_enabled = 0,
        }
    end
    -- If interop is unavailable, Neovim falls back to internal registers
end
