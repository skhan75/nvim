return {
    {
        "scottmckendry/cyberdream.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            require("cyberdream").setup({
                transparent = false,
                italic_comments = true,
                borderless_pickers = false,
            })
            vim.cmd.colorscheme("hack")
        end,
    },
}
