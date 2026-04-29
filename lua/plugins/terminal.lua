return {
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        keys = {
            { "<C-\\>", desc = "Toggle terminal" },
            { "<leader>tt", "<cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
        },
        config = function()
            require("toggleterm").setup({
                size = function(term)
                    if term.direction == "horizontal" then
                        return 15
                    elseif term.direction == "vertical" then
                        return vim.o.columns * 0.35
                    end
                end,
                open_mapping = [[<C-\>]],
                direction = "horizontal",
                shade_terminals = true,
                float_opts = { border = "curved" },
            })
        end,
    },
}
