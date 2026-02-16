return {
    -- Markdown preview in browser
    {
        "iamcco/markdown-preview.nvim",
        build = function() vim.fn["mkdp#util#install"]() end,
        ft = "markdown",
    },

    -- Markdown syntax and folding
    {
        "plasticboy/vim-markdown",
        ft = "markdown",
    },

    -- Auto-wrapping for Markdown
    {
        "preservim/vim-pencil",
        ft = "markdown",
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "markdown",
                callback = function()
                    vim.fn["pencil#init"]({ wrap = "soft" })
                end,
            })
            -- Init for the buffer that triggered the plugin load
            if vim.bo.filetype == "markdown" then
                vim.fn["pencil#init"]({ wrap = "soft" })
            end
        end,
    },

    -- Glow: terminal markdown preview
    {
        "ellisonleao/glow.nvim",
        cmd = "Glow",
        config = function()
            require("glow").setup({ style = "dark", width = 120 })
        end,
    },
}
