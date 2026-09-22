-- Floating terminal: ⌥t shows a shell that is already running, in a glass
-- float over the editor. Loads from ~/workspace/glassterm.nvim here (lazy
-- `dev`), from GitHub elsewhere. Replaces toggleterm's bottom split.
return {
    {
        "skhan75/glassterm.nvim",
        dev = true,
        -- At startup, not on a key: the keymap and the hidden shell have to
        -- exist before the first ⌥t for it to be instant. setup() is cheap.
        lazy = false,
        opts = {
            style = "glass",
            keys = { send = "<leader>ts", rerun = "<leader>tr" },
        },
    },
}
