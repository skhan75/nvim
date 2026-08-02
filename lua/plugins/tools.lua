-- Workflows that were previously impossible in this config.
return {
    -- Project-wide search and replace. <leader>fg could *find* text but nothing
    -- could change it across files. grug-far gives a live-previewing buffer:
    -- type search + replacement, watch every affected line update, then apply
    -- with <localleader>r (localleader is "," -- see init.lua).
    {
        "MagicDuck/grug-far.nvim",
        cmd = { "GrugFar", "GrugFarWithin" },
        opts = { headerMaxWidth = 80 },
        keys = {
            {
                "<leader>sr",
                function() require("grug-far").open() end,
                desc = "Search & replace (project)",
            },
            {
                "<leader>sw",
                function()
                    require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } })
                end,
                desc = "Replace word under cursor",
            },
            {
                "<leader>sf",
                function()
                    require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
                end,
                desc = "Search & replace (this file)",
            },
            {
                "<leader>sr",
                mode = "x",
                function()
                    require("grug-far").open({ visualSelectionUsage = "operate-within-range" })
                end,
                desc = "Replace within selection",
            },
        },
    },

    -- Diagnostics / quickfix workbench. <leader>fd gave a one-shot Telescope
    -- list with no live updates and no grouping.
    -- Deliberately NOT using Trouble's symbols mode -- aerial already owns the
    -- outline, and running both would be two competing UIs for one job.
    {
        "folke/trouble.nvim",
        cmd = "Trouble",
        opts = { focus = true, warn_no_results = false, open_no_results = true },
        keys = {
            { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (project)" },
            { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
            { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
            { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
            { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODOs" },
            { "gR", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP refs/defs" },
        },
    },

    -- Session restore. telescope-project could *find* a project but nothing
    -- restored one, so every nvim started at an empty dashboard.
    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = {},
        keys = {
            { "<leader>pp", function() require("persistence").load() end, desc = "Restore session (cwd)" },
            { "<leader>pl", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
            { "<leader>pd", function() require("persistence").stop() end, desc = "Don't save session" },
            { "<leader>pf", "<cmd>Telescope project<cr>", desc = "Find project" },
        },
    },

    -- Undo history browser. undofile=true was already set, so the history was
    -- being persisted with no way to look at it.
    {
        "mbbill/undotree",
        cmd = "UndotreeToggle",
        keys = {
            { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undo tree" },
        },
        init = function()
            vim.g.undotree_WindowLayout = 2
            vim.g.undotree_SetFocusWhenToggle = 1
        end,
    },
}
