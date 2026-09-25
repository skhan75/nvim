-- Review what Claude changed, comment on the lines, send it back. <leader>v
-- lists the files it touched, <leader>va writes a note, <leader>vs sends the
-- lot to the claude running in the glassterm float. Local checkout via lazy
-- `dev`, GitHub elsewhere.
return {
    {
        "skhan75/volley.nvim",
        dev = true,
        event = "VeryLazy",
        opts = {},
    },
}
