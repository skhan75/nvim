return {
    {
        "rockerBOO/boo-colorscheme-nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("colorscheme forest_stream")
            -- Transparency settings
            vim.api.nvim_set_hl(0, "Normal", { bg = "NONE", ctermbg = "NONE" })
            vim.api.nvim_set_hl(0, "Folded", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "NonText", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
            vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
        end,
    },
}
