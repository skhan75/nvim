-- Test running. Gives per-test pass/fail as virtual text, maps errors back into
-- the buffer, and reuses the DAP config in dap.lua via strategy = "dap".
--
-- Adapters are loaded defensively: an adapter whose module isn't installed
-- would otherwise error at setup and take the whole plugin down.
return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-neotest/nvim-nio",
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "fredrikaverpil/neotest-golang",
            "nvim-neotest/neotest-python",
            "nvim-neotest/neotest-jest",
            "jfpedroza/neotest-elixir",
        },
        keys = {
            { "<leader>nn", function() require("neotest").run.run() end, desc = "Run nearest test" },
            { "<leader>nf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file" },
            { "<leader>nl", function() require("neotest").run.run_last() end, desc = "Run last test" },
            { "<leader>nd", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Debug nearest test" },
            { "<leader>ns", function() require("neotest").summary.toggle() end, desc = "Toggle summary" },
            {
                "<leader>no",
                function() require("neotest").output.open({ enter = true, auto_close = true }) end,
                desc = "Show test output",
            },
            { "<leader>np", function() require("neotest").output_panel.toggle() end, desc = "Toggle output panel" },
            { "<leader>nS", function() require("neotest").run.stop() end, desc = "Stop test run" },
        },
        config = function()
            local adapters = {}
            local function add(module, arg)
                local ok, adapter = pcall(require, module)
                if not ok then return end
                table.insert(adapters, arg and adapter(arg) or adapter)
            end

            add("neotest-golang")
            add("neotest-python", { dap = { justMyCode = false } })
            add("neotest-jest", { jestCommand = "npm test --" })
            add("neotest-elixir")

            require("neotest").setup({
                adapters = adapters,
                status = { virtual_text = true },
                output = { open_on_run = false },
            })
        end,
    },
}
