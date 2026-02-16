return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        keys = {
            { "<leader>gl", function() require("gitsigns").toggle_linehl() end, desc = "Toggle Git line highlights" },
            { "<leader>gsh", function() require("gitsigns").stage_hunk() end, desc = "Stage hunk" },
            { "<leader>guh", function() require("gitsigns").reset_hunk() end, desc = "Undo hunk" },
            { "<leader>gp", function() require("gitsigns").preview_hunk() end, desc = "Preview hunk" },
            { "<leader>gnh", function() require("gitsigns").next_hunk() end, desc = "Next hunk" },
            { "<leader>gph", function() require("gitsigns").prev_hunk() end, desc = "Previous hunk" },
            { "<leader>gr", function() require("gitsigns").reset_buffer() end, desc = "Reset buffer" },
            { "<leader>gS", function() require("gitsigns").stage_buffer() end, desc = "Stage buffer" },
            { "<leader>gd", function() require("gitsigns").toggle_deleted() end, desc = "Toggle deleted lines" },
            { "<leader>gw", function() require("gitsigns").toggle_word_diff() end, desc = "Toggle word diff" },
            { "<leader>gB", function() require("gitsigns").toggle_current_line_blame() end, desc = "Toggle line blame" },
            { "<leader>gbl", function() require("gitsigns").blame_line() end, desc = "Blame line" },
        },
        config = function()
            require("gitsigns").setup()
        end,
    },
}
