return {
    -- Gitsigns: inline git change indicators + hunk operations
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("gitsigns").setup({
                signs = {
                    add          = { text = "│" },
                    change       = { text = "│" },
                    delete       = { text = "_" },
                    topdelete    = { text = "‾" },
                    changedelete = { text = "~" },
                    untracked    = { text = "┆" },
                },
                on_attach = function(bufnr)
                    local gs = require("gitsigns")
                    local function bmap(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
                    end

                    -- ── Hunk navigation ───────────────────────────────
                    -- Moved off ]c/[c, which belong to native diff mode. The
                    -- old maps tried to fall through to native diff by
                    -- returning "]c" from the callback, but that only works
                    -- with expr = true, which was never set -- so the return
                    -- value was discarded and ]c/[c were dead keys inside
                    -- Diffview.
                    bmap("n", "]h", function() gs.nav_hunk("next") end, "Next git hunk")
                    bmap("n", "[h", function() gs.nav_hunk("prev") end, "Prev git hunk")

                    -- ── Hunk actions ──────────────────────────────────
                    -- <leader>gh / <leader>gL avoid the prefix collisions the
                    -- old <leader>gsh and <leader>gbl created with the
                    -- Telescope <leader>gs and <leader>gb pickers, each of
                    -- which used to stall for the full timeoutlen.
                    bmap("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
                    bmap("n", "<leader>gi", gs.preview_hunk_inline, "Preview hunk inline")
                    bmap("n", "<leader>gh", gs.stage_hunk, "Stage hunk")
                    bmap("n", "<leader>gu", gs.reset_hunk, "Reset hunk (undo)")
                    bmap("v", "<leader>gh", function()
                        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                    end, "Stage selected lines")
                    bmap("n", "<leader>gS", gs.stage_buffer, "Stage entire buffer")
                    bmap("n", "<leader>gR", gs.reset_buffer, "Reset entire buffer")

                    -- ── Toggles ───────────────────────────────────────
                    bmap("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle line blame")
                    bmap("n", "<leader>gL", gs.blame_line, "Blame current line")
                    bmap("n", "<leader>gw", gs.toggle_word_diff, "Toggle word diff")
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
