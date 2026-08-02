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
opt.ruler = true
opt.laststatus = 3
opt.incsearch = true
opt.showmatch = true
opt.visualbell = true
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
opt.foldmethod = "marker"
opt.colorcolumn = "80"
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
opt.synmaxcol = 240
opt.updatetime = 200
opt.lazyredraw = false

-- Misc
opt.shortmess:append("c")
opt.whichwrap:append("<,>,[,],h,l")
opt.iskeyword:append("-")
opt.hlsearch = false

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

-- Highlight on yank (built-in, no plugin needed)
vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
    callback = function()
        vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
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
