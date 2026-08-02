return {
    -- Harpoon v2.
    --
    -- v1 (the `master` branch) has been unmaintained since Aug 2024. More
    -- importantly the jump keys were <leader>h1..h4 -- four keystrokes plus a
    -- 300ms leader pause for the one thing harpoon exists to make instant.
    -- <M-1>..<M-4> are single chords and were completely free in this config.
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = function()
            local h = function() return require("harpoon") end
            local keys = {
                { "<leader>ha", function() h():list():add() end, desc = "Harpoon add file" },
                {
                    "<leader>hh",
                    function()
                        h().ui:toggle_quick_menu(h():list(), { border = "rounded", title_pos = "center" })
                    end,
                    desc = "Harpoon menu",
                },
                { "<C-e>", function() h().ui:toggle_quick_menu(h():list()) end, desc = "Harpoon menu" },
                { "[h", function() h():list():prev() end, desc = "Harpoon prev" },
                { "]h", function() h():list():next() end, desc = "Harpoon next" },
            }
            for i = 1, 4 do
                table.insert(keys, {
                    "<M-" .. i .. ">",
                    function() h():list():select(i) end,
                    desc = "Harpoon file " .. i,
                })
            end
            return keys
        end,
        config = function()
            require("harpoon"):setup({
                settings = { save_on_toggle = true, sync_on_ui_close = true },
            })
        end,
    },
}
