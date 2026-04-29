local map = vim.keymap.set

-- Escape
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Disable space in normal mode (reserved for leader)
map("", "<Space>", "<Nop>", { noremap = true, silent = true })

-- Move line/selection up and down with Shift+J / Shift+K
map("n", "J", ":m .+1<CR>==", { desc = "Move line down", silent = true })
map("n", "K", ":m .-2<CR>==", { desc = "Move line up", silent = true })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

-- Resize with arrows
map("n", "<C-Up>", ":resize -2<CR>", { desc = "Decrease window height", silent = true })
map("n", "<C-Down>", ":resize +2<CR>", { desc = "Increase window height", silent = true })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width", silent = true })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width", silent = true })

-- Save and Quit
map("n", "<leader>w", "<cmd>w!<CR>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>q!<CR>", { desc = "Quit" })

-- Yank & Delete entire file (uses command mode for reliability)
map("n", "<leader>ya", "<cmd>%y<CR>", { desc = "Yank entire file" })
map("n", "<leader>da", "<cmd>%d<CR>", { desc = "Delete entire file contents" })

-- Clear search highlights
map("n", "<leader>hc", ":noh<CR>", { desc = "Clear search highlights", silent = true })

-- Delete word in insert mode (Alt+Backspace)
map("i", "<M-BS>", "<C-w>", { desc = "Delete word backwards" })

-- Window navigation (Ctrl+w shortcuts preserved for NvimTree / split toggling)
map("n", "<C-w>w", "<C-w>w", { desc = "Cycle to next window" })
map("n", "<C-w>h", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-w>j", "<C-w>j", { desc = "Move to below window" })
map("n", "<C-w>k", "<C-w>k", { desc = "Move to above window" })
map("n", "<C-w>l", "<C-w>l", { desc = "Move to right window" })

-- ─── AI (Cursor-style shortcuts) ────────────────────────────────────────
-- Ctrl+L  = toggle Claude sidebar  (like Cursor's Ctrl+L)
map("n", "<C-l>", function()
    _G.ClaudeSidebar.toggle()
end, { desc = "AI: Toggle Claude sidebar", silent = true })
map("v", "<C-l>", function()
    _G.ClaudeSidebar.toggle()
end, { desc = "AI: Toggle Claude sidebar", silent = true })

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
