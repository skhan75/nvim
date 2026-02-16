return {
    {
        "goolord/alpha-nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VimEnter",
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {
                "                                                     ",
                "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
                "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
                "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
                "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
                "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
                "                                                     ",
            }

            dashboard.section.buttons.val = {
                dashboard.button("f", "  Find file",       "<cmd>Telescope find_files<CR>"),
                dashboard.button("r", "  Recent files",    "<cmd>Telescope oldfiles<CR>"),
                dashboard.button("g", "  Search text",     "<cmd>Telescope live_grep<CR>"),
                dashboard.button("p", "  Projects",        "<cmd>Telescope project<CR>"),
                dashboard.button("c", "  Config",          "<cmd>Telescope find_files cwd=~/.config/nvim<CR>"),
                dashboard.button("a", "  AI Chat",         "<cmd>AvanteAsk<CR>"),
                dashboard.button("l", "󰒲  Lazy (plugins)",  "<cmd>Lazy<CR>"),
                dashboard.button("q", "  Quit",            "<cmd>qa<CR>"),
            }

            dashboard.section.header.opts.hl = "AlphaHeader"
            dashboard.section.buttons.opts.hl = "AlphaButtons"

            dashboard.section.footer.val = function()
                local stats = require("lazy").stats()
                return "  "
                    .. stats.loaded .. "/" .. stats.count .. " plugins"
                    .. "   " .. (math.floor(stats.startuptime * 100 + 0.5) / 100) .. "ms"
            end
            dashboard.section.footer.opts.hl = "AlphaFooter"

            dashboard.config.layout = {
                { type = "padding", val = 4 },
                dashboard.section.header,
                { type = "padding", val = 2 },
                dashboard.section.buttons,
                { type = "padding", val = 1 },
                dashboard.section.footer,
            }

            alpha.setup(dashboard.config)

            -- Hide tabline and statusline on dashboard
            vim.api.nvim_create_autocmd("User", {
                pattern = "AlphaReady",
                callback = function()
                    vim.opt_local.showtabline = 0
                    vim.opt_local.laststatus = 0
                end,
            })
            vim.api.nvim_create_autocmd("User", {
                pattern = "AlphaClosed",
                callback = function()
                    vim.opt.showtabline = 2
                    vim.opt.laststatus = 3
                end,
            })
        end,
    },
}
