-- tail -f for open files: edits made by anything other than me (Claude in the
-- glassterm float, a formatter, a rebase) land in the buffer and stay
-- highlighted until I save. Local checkout via lazy `dev`, GitHub elsewhere.
return {
    {
        "skhan75/tailf.nvim",
        dev = true,
        event = "VeryLazy",
        opts = {},
        keys = {
            { "]d", "<cmd>Tailf next<cr>", desc = "Next external change" },
            { "[d", "<cmd>Tailf prev<cr>", desc = "Previous external change" },
        },
    },
}
