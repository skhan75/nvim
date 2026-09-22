local map = vim.keymap.set

-- Escape
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- NOTE: <Space> is deliberately NOT mapped to <Nop>.
-- With mapleader = " ", mapping <Space> itself creates a *complete* mapping that
-- is a prefix of every single leader binding. Neovim then has to wait out
-- timeoutlen to disambiguate, so pausing mid-sequence fires <Nop> and drops the
-- rest of the keys -- which also stops which-key from holding its popup open.
-- Leaving <Space> unmapped is what makes it a clean prefix.

-- Move line/selection up and down.
-- These were on J/K, which destroyed `K` (LSP hover / keywordprg) and `J` (join)
-- with no replacement. Alt is where every other editor puts line-shifting, and
-- it also works from insert mode.
map("n", "<M-j>", "<cmd>m .+1<CR>==", { desc = "Move line down" })
map("n", "<M-k>", "<cmd>m .-2<CR>==", { desc = "Move line up" })
map("v", "<M-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("v", "<M-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })
map("i", "<M-j>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move line down" })
map("i", "<M-k>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move line up" })

-- Join, restored -- and improved so the cursor doesn't leap to the seam.
map("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })

-- Window navigation. <C-l> and <C-k> are free now that the Claude sidebar moved
-- to <leader>a* and signature help uses the built-in insert-mode <C-s>.
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- Resize with arrows
map("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease window height", silent = true })
map("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase window height", silent = true })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width", silent = true })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width", silent = true })

-- Save and Quit. `q!` on the primary quit key discards unsaved work silently;
-- `confirm q` prompts instead. <leader>Q keeps the old force-quit escape hatch.
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>confirm q<CR>", { desc = "Quit" })
map("n", "<leader>Q", "<cmd>qa!<CR>", { desc = "Force quit all" })

-- Yank & Delete entire file (uses command mode for reliability)
map("n", "<leader>ya", "<cmd>%y<CR>", { desc = "Yank entire file" })
map("n", "<leader>da", "<cmd>%d<CR>", { desc = "Delete entire file contents" })

-- Clear search highlights. <Esc> is the idiomatic binding and frees <leader>hc,
-- which was mis-filed under the Harpoon which-key group.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights", silent = true })

-- Delete word in insert mode (Alt+Backspace)
map("i", "<M-BS>", "<C-w>", { desc = "Delete word backwards" })

-- ─── Terminal mode ──────────────────────────────────────────────────────
-- There were no terminal-mode maps at all, so leaving the Claude sidebar or
-- a terminal meant typing <C-\><C-n> then <C-w>h every time.
-- Alt, not Ctrl: the Claude TUI and shell readline consume the Ctrl variants.
map("t", "<M-h>", "<C-\\><C-n><C-w>h", { desc = "Terminal → window left" })
map("t", "<M-j>", "<C-\\><C-n><C-w>j", { desc = "Terminal → window down" })
map("t", "<M-k>", "<C-\\><C-n><C-w>k", { desc = "Terminal → window up" })
map("t", "<M-l>", "<C-\\><C-n><C-w>l", { desc = "Terminal → window right" })
map("t", "<M-a>", function() _G.ClaudeSidebar.toggle() end, { desc = "Toggle Claude sidebar" })

-- Terminal buffers: no line numbers, no sign column, start in insert.
vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("term_open", { clear = true }),
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
        vim.cmd("startinsert")
    end,
})

-- ─── AI ─────────────────────────────────────────────────────────────────
-- Alt+A toggles the Claude sidebar. This was <C-l>, which blocked the standard
-- <C-hjkl> window-navigation quad; <leader>aa / <leader>af also still work.
map({ "n", "v" }, "<M-a>", function()
    _G.ClaudeSidebar.toggle()
end, { desc = "AI: Toggle Claude sidebar", silent = true })

-- ─── Quality of life ────────────────────────────────────────────────────
map("n", "<leader><leader>", "<cmd>Telescope buffers<CR>", { desc = "Switch buffer" })
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev match (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("v", "<", "<gv", { desc = "Outdent, keep selection" })
map("v", ">", ">gv", { desc = "Indent, keep selection" })
-- Paste over a selection without losing the yank register.
map("x", "<leader>p", '"_dP', { desc = "Paste without clobbering register" })
map("n", "<leader>L", "<cmd>Lazy<CR>", { desc = "Lazy (plugins)" })
map("n", "<leader>M", "<cmd>Mason<CR>", { desc = "Mason (LSP installer)" })

-- ─── Change review ──────────────────────────────────────────────────
-- Open diff view to see ALL uncommitted changes across files
map("n", "<leader>gD", "<cmd>DiffviewOpen<CR>", { desc = "Review all changes (diff view)", silent = true })

-- Quickfix list of all modified files (jump between them with ]q / [q)
map("n", "<leader>gm", function()
    local handle = io.popen("git diff --name-only 2>/dev/null; git diff --name-only --cached 2>/dev/null")
    if not handle then
        vim.notify("Not in a git repo", vim.log.levels.WARN)
        return
    end
    local result = handle:read("*a")
    handle:close()
    local files = {}
    local seen = {}
    for file in result:gmatch("[^\n]+") do
        if not seen[file] then
            seen[file] = true
            table.insert(files, { filename = file, lnum = 1, text = "modified" })
        end
    end
    if #files == 0 then
        vim.notify("No modified files", vim.log.levels.INFO)
        return
    end
    vim.fn.setqflist(files, "r")
    vim.cmd("copen")
    vim.notify(#files .. " modified file(s) in quickfix", vim.log.levels.INFO)
end, { desc = "List modified files (quickfix)", silent = true })

-- Fast quickfix navigation
map("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix item", silent = true })
map("n", "[q", "<cmd>cprev<CR>zz", { desc = "Prev quickfix item", silent = true })
