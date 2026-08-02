-- Markdown.
--
-- Removed three of the five plugins that were here:
--   plasticboy/vim-markdown -- Vimscript regex syntax plus its own foldexpr,
--     both of which fight the treesitter markdown parser and render-markdown.
--     The repo also moved to preservim years ago.
--   preservim/vim-pencil -- unmaintained since 2023; its "soft wrap" mode is
--     wrap + linebreak + breakindent + nolist, now a FileType autocmd in
--     config/options.lua.
--   ellisonleao/glow.nvim -- the `glow` binary is not installed, so :Glow was
--     a dead command.
return {
    -- Markdown preview in the browser.
    -- Note: if :MarkdownPreview fails, run `:Lazy build markdown-preview.nvim`
    -- -- the build step had never completed.
    {
        "iamcco/markdown-preview.nvim",
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
        ft = "markdown",
        keys = {
            { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Toggle markdown preview" },
        },
    },

    -- In-buffer rendering. conceallevel is set to 3 for markdown in
    -- config/options.lua; the previous global conceallevel=0 meant this plugin
    -- could only ever do half its job.
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        ft = { "markdown" },
        opts = {
            file_types = { "markdown" },
            completions = { blink = { enabled = true } },
        },
    },
}
