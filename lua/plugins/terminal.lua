return {
    {
        "akinsho/toggleterm.nvim",
        version = "*",
        keys = {
            { "<C-\\>", desc = "Toggle terminal" },
            { "<leader>tc", desc = "Open Claude CLI" },
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

            -- Dedicated Claude CLI terminal
            local Terminal = require("toggleterm.terminal").Terminal
            local claude_term = Terminal:new({
                cmd = "claude",
                direction = "vertical",
                close_on_exit = false,
            })
            vim.keymap.set("n", "<leader>tc", function()
                claude_term:toggle()
            end, { desc = "Toggle Claude CLI" })
        end,
    },
}
