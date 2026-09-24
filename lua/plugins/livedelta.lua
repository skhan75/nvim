-- Live diff of edits made by anything other than you: Claude in the glassterm
-- float, a formatter, a rebase. The file reloads in place and what changed
-- stays highlighted until you save.
--
-- Local-only path for now; switch to "skhan75/livedelta.nvim" with dev = true
-- once the repo is published.
return {
    {
        dir = "~/workspace/livedelta.nvim",
        name = "livedelta.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "]d", "<cmd>LiveDelta next<cr>", desc = "Next external change" },
            { "[d", "<cmd>LiveDelta prev<cr>", desc = "Previous external change" },
        },
    },
}
