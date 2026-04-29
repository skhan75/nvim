return {
    {
        "goolord/alpha-nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VimEnter",
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            -- Cyberdream gradient header colors (cyan -> blue -> magenta)
            local header_colors = {
                { "AlphaHL1", { fg = "#5ef1ff" } },
                { "AlphaHL2", { fg = "#5ef1ff" } },
                { "AlphaHL3", { fg = "#5ea1ff" } },
                { "AlphaHL4", { fg = "#bd5eff" } },
                { "AlphaHL5", { fg = "#bd5eff" } },
                { "AlphaHL6", { fg = "#ff5ef1" } },
                { "AlphaHL7", { fg = "#ff6e5e" } },
                { "AlphaHL8", { fg = "#ff6e5e" } },
            }
            for _, hl in ipairs(header_colors) do
                vim.api.nvim_set_hl(0, hl[1], hl[2])
            end

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

            dashboard.section.header.opts.hl = {}
            for i = 1, #dashboard.section.header.val do
                dashboard.section.header.opts.hl[i] = { { header_colors[i][1], 0, -1 } }
            end

            dashboard.section.buttons.val = {
                dashboard.button("f", "  Find file",       "<cmd>Telescope find_files<CR>"),
                dashboard.button("r", "  Recent files",    "<cmd>Telescope oldfiles<CR>"),
                dashboard.button("g", "  Search text",     "<cmd>Telescope live_grep<CR>"),
                dashboard.button("p", "  Projects",        "<cmd>Telescope project<CR>"),
                dashboard.button("c", "  Config",          "<cmd>Telescope find_files cwd=~/.config/nvim<CR>"),
                dashboard.button("a", "󱙺  Claude Code",      "<cmd>lua _G.ClaudeSidebar.toggle()<CR>"),
                dashboard.button("l", "󰒲  Lazy (plugins)",  "<cmd>Lazy<CR>"),
                dashboard.button("q", "  Quit",            "<cmd>qa<CR>"),
            }

            -- Style each button shortcut key
            for _, button in ipairs(dashboard.section.buttons.val) do
                button.opts.hl = "AlphaButtons"
                button.opts.hl_shortcut = "AlphaShortcut"
            end

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
