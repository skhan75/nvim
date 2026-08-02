-- Debugging. Scoped deliberately to Go and Python, where the adapters are
-- essentially one setup() call each.
--
-- Not included, on purpose:
--   JS/TS -- vscode-js-debug needs distinct configs for node vs browser vs Jest
--     and the Neovim adapter lags upstream; `node --inspect` is less pain.
--   Elixir -- elixir-ls's DAP is test-only and the community norm is dbg/IEx.pry.
--   Java  -- comes free via nvim-jdtls's setup_dap(), if jdtls is added later.
return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
            "theHamsta/nvim-dap-virtual-text",
            { "jay-babu/mason-nvim-dap.nvim", dependencies = { "mason-org/mason.nvim" } },
            "leoluz/nvim-dap-go",
            "mfussenegger/nvim-dap-python",
        },
        keys = {
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
            {
                "<leader>dB",
                function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
                desc = "Conditional breakpoint",
            },
            { "<leader>dc", function() require("dap").continue() end, desc = "Continue / start" },
            { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
            { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
            { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
            { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
            { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
            { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
            {
                "<leader>de",
                function() require("dapui").eval(nil, { enter = true }) end,
                mode = { "n", "v" },
                desc = "Evaluate expression",
            },
        },
        config = function()
            local dap, dapui = require("dap"), require("dapui")

            dapui.setup()
            require("nvim-dap-virtual-text").setup({ commented = true })

            require("mason-nvim-dap").setup({
                ensure_installed = { "delve", "python", "codelldb" },
                automatic_installation = true,
                handlers = {},
            })

            require("dap-go").setup()
            local debugpy = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
            if vim.fn.executable(debugpy) == 1 then
                require("dap-python").setup(debugpy)
            end

            -- Open the UI automatically when a session starts, close it after.
            dap.listeners.before.attach.dapui = function() dapui.open() end
            dap.listeners.before.launch.dapui = function() dapui.open() end
            dap.listeners.before.event_terminated.dapui = function() dapui.close() end
            dap.listeners.before.event_exited.dapui = function() dapui.close() end

            vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError" })
            vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticWarn" })
            vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticWarn", linehl = "Visual" })
        end,
    },
}
