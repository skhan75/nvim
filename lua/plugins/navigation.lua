return {
    -- Harpoon: quick file navigation
    {
        "ThePrimeagen/harpoon",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>ha", function() require("harpoon.mark").add_file() end, desc = "Add file to Harpoon" },
            { "<leader>hh", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Toggle Harpoon menu" },
            { "<leader>h1", function() require("harpoon.ui").nav_file(1) end, desc = "Go to Harpoon file 1" },
            { "<leader>h2", function() require("harpoon.ui").nav_file(2) end, desc = "Go to Harpoon file 2" },
            { "<leader>h3", function() require("harpoon.ui").nav_file(3) end, desc = "Go to Harpoon file 3" },
            { "<leader>h4", function() require("harpoon.ui").nav_file(4) end, desc = "Go to Harpoon file 4" },
        },
    },
}
