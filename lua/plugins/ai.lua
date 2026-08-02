-- Claude Code: Right-side AI terminal sidebar (Cursor-style)
-- Opens the `claude` CLI in a persistent vertical split on the right.

local claude_buf = nil
local claude_win = nil

local function is_claude_open()
    return claude_win ~= nil and vim.api.nvim_win_is_valid(claude_win)
end

local function get_claude_width()
    return math.floor(vim.o.columns * 0.38)
end

local function style_claude_win(win)
    vim.api.nvim_set_option_value("number", false, { win = win })
    vim.api.nvim_set_option_value("relativenumber", false, { win = win })
    vim.api.nvim_set_option_value("signcolumn", "no", { win = win })
    vim.api.nvim_set_option_value("foldcolumn", "0", { win = win })
    vim.api.nvim_set_option_value("winfixwidth", true, { win = win })
    vim.api.nvim_set_option_value("winbar", "%#ClaudeTitle# 󱙺 Claude Code %*", { win = win })
end

local function open_claude()
    if is_claude_open() then
        vim.api.nvim_set_current_win(claude_win)
        vim.cmd("startinsert")
        return
    end

    -- Open a vertical split on the right.
    -- Reuse path uses `vsplit`, not `vnew`: `vnew` creates a throwaway empty
    -- buffer that was orphaned the moment we swapped the terminal back in,
    -- leaking one buffer per toggle.
    if claude_buf and vim.api.nvim_buf_is_valid(claude_buf) then
        vim.cmd("botright vsplit")
        claude_win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(claude_win, claude_buf)
    else
        vim.cmd("botright vnew")
        claude_win = vim.api.nvim_get_current_win()

        -- Launch claude CLI in the new buffer.
        -- jobstart{term=true} replaces termopen(), deprecated since 0.11.
        vim.fn.jobstart("claude", {
            term = true,
            on_exit = function()
                claude_buf = nil
            end,
        })
        claude_buf = vim.api.nvim_get_current_buf()

        -- Buffer-local options
        vim.api.nvim_set_option_value("buflisted", false, { buf = claude_buf })
        vim.api.nvim_set_option_value("bufhidden", "hide", { buf = claude_buf })
        vim.api.nvim_buf_set_name(claude_buf, "claude://chat")
    end

    vim.api.nvim_win_set_width(claude_win, get_claude_width())
    style_claude_win(claude_win)
    vim.cmd("startinsert")
end

local function close_claude()
    if is_claude_open() then
        vim.api.nvim_win_close(claude_win, false)
        claude_win = nil
    end
end

local function toggle_claude()
    if is_claude_open() then
        close_claude()
    else
        open_claude()
    end
end

local function focus_claude()
    if is_claude_open() then
        vim.api.nvim_set_current_win(claude_win)
        vim.cmd("startinsert")
    else
        open_claude()
    end
end

-- Restore styling when re-entering the Claude window (e.g. after splits change)
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        if claude_buf and vim.api.nvim_get_current_buf() == claude_buf then
            local win = vim.api.nvim_get_current_win()
            claude_win = win
            style_claude_win(win)
        end
    end,
})

-- Track window closure
vim.api.nvim_create_autocmd("WinClosed", {
    callback = function(args)
        local closed_win = tonumber(args.match)
        if closed_win == claude_win then
            claude_win = nil
        end
    end,
})

-- ─── Keymaps ──────────────────────────────────────────────────────────
vim.keymap.set("n", "<leader>aa", toggle_claude, { desc = "Toggle Claude sidebar" })
vim.keymap.set("n", "<leader>at", toggle_claude, { desc = "Toggle Claude sidebar" })
vim.keymap.set("n", "<leader>af", focus_claude, { desc = "Focus Claude sidebar" })
vim.keymap.set("n", "<leader>aq", close_claude, { desc = "Close Claude sidebar" })

-- ─── Expose for other modules (lualine, keymaps) ─────────────────────
_G.ClaudeSidebar = {
    toggle = toggle_claude,
    open = open_claude,
    close = close_claude,
    focus = focus_claude,
    is_open = is_claude_open,
}

return {
    -- Render Markdown nicely in chat buffers and markdown files
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown" },
        opts = {
            file_types = { "markdown" },
        },
    },
}
