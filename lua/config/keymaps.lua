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
-- Ctrl+L  = open / focus the AI chat sidebar  (like Cursor's Ctrl+L)
-- Ctrl+K  = AI edit on selected code           (like Cursor's Ctrl+K)
map("n", "<C-l>", function()
    require("avante.api").ask()
end, { desc = "AI: Open chat sidebar", silent = true })
map("v", "<C-l>", function()
    require("avante.api").ask()
end, { desc = "AI: Ask about selection", silent = true })

map("v", "<C-k>", function()
    require("avante.api").edit()
end, { desc = "AI: Edit selection inline", silent = true })

-- <leader>as = switch between Claude and GPT
map("n", "<leader>as", function()
    local cfg = require("avante.config")
    local current = cfg.provider or "claude"
    local next_provider = current == "claude" and "openai" or "claude"
    cfg.override({ provider = next_provider })
    vim.notify("AI switched to: " .. next_provider, vim.log.levels.INFO)
end, { desc = "AI: Switch provider (Claude/GPT)" })
