-- snacks.nvim earns its place here by *subtracting*: it replaces
-- indent-blankline, nvim-notify, dressing.nvim and alpha-nvim with one
-- lazy-loaded surface that shares highlight conventions across modules.
--
-- The picker and explorer modules are deliberately left off -- telescope is
-- deeply wired into this config (5 extensions, ~25 keymaps, a tuned ignore
-- list) and swapping it would cost a week of muscle memory for a marginal gain.
return {
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            -- Replaces indent-blankline. Extmark-based, renders only the
            -- viewport, and needs no hand-maintained exclusion list.
            indent = {
                indent = { char = "│", hl = "SnacksIndent" },
                scope = { char = "│", hl = "SnacksIndentScope", underline = false },
                chunk = { enabled = false },
                -- Animation off permanently: motion in peripheral vision on
                -- every cursor move is the opposite of calm, and on WSL2 it smears.
                animate = { enabled = false },
            },

            -- Fixed lanes for marks/diagnostics/git/folds, so the gutter stops
            -- shifting the buffer sideways as signs appear and clear.
            statuscolumn = {
                left = { "mark", "sign" },
                right = { "fold", "git" },
                folds = { open = true, git_hl = true },
                refresh = 50,
            },

            -- Replaces dressing.nvim (archived) and nvim-notify (whose
            -- hardcoded #000000 background never matched the hack palette).
            input = { enabled = true },
            notifier = {
                enabled = true,
                style = "minimal",
                timeout = 2500,
                top_down = false, -- bottom-right: never covers what you just wrote
                margin = { top = 0, right = 1, bottom = 1 },
            },

            -- Replaces alpha-nvim. Monochrome and small: the old dashboard used
            -- a cyan-to-magenta gradient from cyberdream's palette, which
            -- appeared nowhere else on screen.
            dashboard = {
                preset = {
                    header = table.concat({
                        "",
                        "  ▄▄▄  ▄   ▄ ▄ ▄▄▄▄▄▄ ",
                        "  █ █  █   █ █ █  █  █ ",
                        "  █  █  ▀▄▀  █ █  █  █ ",
                        "",
                    }, "\n"),
                    keys = {
                        { icon = " ", key = "f", desc = "Find file", action = ":Telescope find_files" },
                        { icon = " ", key = "g", desc = "Search text", action = ":Telescope live_grep" },
                        { icon = " ", key = "r", desc = "Recent files", action = ":Telescope oldfiles" },
                        { icon = " ", key = "p", desc = "Restore session", action = ":lua require('persistence').load()" },
                        { icon = " ", key = "c", desc = "Config", action = ":Telescope find_files cwd=~/.config/nvim" },
                        { icon = "󱙺 ", key = "a", desc = "Claude Code", action = ":lua _G.ClaudeSidebar.toggle()" },
                        { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
                        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
                    },
                },
                sections = {
                    { section = "header" },
                    { section = "keys", gap = 0, padding = 2 },
                    { section = "startup" },
                },
            },

            bigfile = { enabled = true },   -- disables TS/LSP on >1.5MB files
            quickfile = { enabled = true }, -- paints the buffer before plugins load
            words = { enabled = true },     -- subtle LSP reference underline
            scroll = { enabled = true, animate = { duration = { step = 12, total = 120 } } },

            -- Focus mode. snacks.dim is scope-based (treesitter), so it dims the
            -- function you're not in rather than the split you're not in.
            dim = { enabled = true },
            zen = {
                toggles = { dim = true, git_signs = false },
                show = { statusline = false, tabline = false },
                win = { backdrop = { transparent = true, blend = 96 }, width = 100 },
            },
            scratch = { enabled = true, win = { border = "rounded" } },
        },
        keys = {
            { "<leader>z", function() Snacks.zen() end, desc = "Zen mode" },
            { "<leader>Z", function() Snacks.zen.zoom() end, desc = "Zoom window" },
            { "<leader>.", function() Snacks.scratch() end, desc = "Scratch buffer" },
            -- <leader>X, not <leader>x: the Trouble group owns <leader>x*, and a
            -- complete <leader>x map would make every one of those wait out
            -- timeoutlen first.
            { "<leader>X", function() Snacks.notifier.hide() end, desc = "Dismiss notifications" },
            { "]]", function() Snacks.words.jump(1) end, desc = "Next reference" },
            { "[[", function() Snacks.words.jump(-1) end, desc = "Prev reference" },
        },
    },
}
