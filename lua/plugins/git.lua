return {
    -- Gitsigns: inline git change indicators + hunk operations
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("gitsigns").setup({
                signs = {
                    add          = { text = "▎" },
                    change       = { text = "▎" },
                    delete       = { text = "" },
                    topdelete    = { text = "" },
                    changedelete = { text = "▎" },
                    untracked    = { text = "▎" },
                },
                on_attach = function(bufnr)
                    local gs = require("gitsigns")
                    local function bmap(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
                    end

                    -- ── Fast hunk navigation ──────────────────────────
                    bmap("n", "]c", function()
                        if vim.wo.diff then return "]c" end
                        vim.schedule(function() gs.nav_hunk("next") end)
                        return "<Ignore>"
                    end, "Next git change")
                    bmap("n", "[c", function()
                        if vim.wo.diff then return "[c" end
                        vim.schedule(function() gs.nav_hunk("prev") end)
                        return "<Ignore>"
                    end, "Prev git change")

                    -- ── Hunk actions ──────────────────────────────────
                    bmap("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
                    bmap("n", "<leader>gi", gs.preview_hunk_inline, "Preview hunk inline")
                    bmap("n", "<leader>gsh", gs.stage_hunk, "Stage hunk")
                    bmap("n", "<leader>guh", gs.reset_hunk, "Reset hunk (undo)")
                    bmap("n", "<leader>gS", gs.stage_buffer, "Stage entire buffer")
                    bmap("n", "<leader>gr", gs.reset_buffer, "Reset entire buffer")

                    -- ── Toggles ───────────────────────────────────────
                    bmap("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle line blame")
                    bmap("n", "<leader>gd", gs.toggle_deleted, "Toggle deleted lines")
                    bmap("n", "<leader>gw", gs.toggle_word_diff, "Toggle word diff")
                    bmap("n", "<leader>gl", gs.toggle_linehl, "Toggle git line highlights")
                    bmap("n", "<leader>gbl", gs.blame_line, "Blame current line")
                end,
            })
        end,
    },

    -- Diffview: full file-level diff browser (like VS Code source control)
    {
        "sindrets/diffview.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
        keys = {
            { "<leader>gD", "<cmd>DiffviewOpen<CR>", desc = "Open diff view (all changes)" },
            { "<leader>gH", "<cmd>DiffviewFileHistory %<CR>", desc = "File history (current file)" },
            { "<leader>gQ", "<cmd>DiffviewClose<CR>", desc = "Close diff view" },
        },
        config = function()
            require("diffview").setup({
                enhanced_diff_hl = true,
                view = {
                    default = { layout = "diff2_horizontal" },
                    merge_tool = { layout = "diff3_mixed" },
                },
                file_panel = {
                    listing_style = "tree",
                    tree_options = { flatten_dirs = true, folder_statuses = "only_folded" },
                    win_config = { position = "left", width = 35 },
                },
                keymaps = {
                    view = {
                        { "n", "<Tab>",   "<cmd>DiffviewFocusFiles<CR>", { desc = "Focus file panel" } },
                        { "n", "q",       "<cmd>DiffviewClose<CR>",      { desc = "Close diff view" } },
                    },
                    file_panel = {
                        { "n", "j",       "j",                          { desc = "Next file" } },
                        { "n", "k",       "k",                          { desc = "Prev file" } },
                        { "n", "<CR>",    "<cmd>DiffviewFocusFiles<CR>", { desc = "Open diff" } },
                        { "n", "q",       "<cmd>DiffviewClose<CR>",      { desc = "Close diff view" } },
                        { "n", "<Tab>",   "<cmd>DiffviewFocusFiles<CR>", { desc = "Toggle focus" } },
                    },
                },
            })
        end,
    },
}
