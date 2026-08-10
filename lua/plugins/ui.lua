return {
    -- Icons: one set, one source of truth. nvim-web-devicons and mini.icons were
    -- both declared before (mini.icons was never even required). mini.icons
    -- impersonates devicons so dependent plugins keep working.
    {
        "echasnovski/mini.icons",
        version = "*",
        lazy = true,
        init = function()
            package.preload["nvim-web-devicons"] = function()
                require("mini.icons").mock_nvim_web_devicons()
                return package.loaded["nvim-web-devicons"]
            end
        end,
        opts = {},
    },

    -- Status line.
    --
    -- Two fixes: the theme was "cyberdream" (blue/magenta/orange) while the
    -- editor loads "hack" (teal) -- the statusline was literally a different
    -- colorscheme. And ten components is about six too many: `encoding` reads
    -- utf-8 forever, `fileformat` reads unix forever, and `progress` duplicates
    -- `location`. Mode is a single letter because the colour already tells you.
    {
        "nvim-lualine/lualine.nvim",
        event = "VeryLazy",
        config = function()
            local p = _G.HackPalette
            local theme = "auto"

            if p then
                local mid = { bg = p.bg_alt, fg = p.fg_muted }
                local tail = { bg = p.bg_alt, fg = p.fg_dim }
                theme = {
                    normal = { a = { fg = p.bg, bg = p.teal_hi, gui = "bold" }, b = mid, c = tail },
                    insert = { a = { fg = p.bg, bg = p.sage, gui = "bold" }, b = mid, c = tail },
                    visual = { a = { fg = p.bg, bg = p.amber, gui = "bold" }, b = mid, c = tail },
                    replace = { a = { fg = p.bg, bg = p.coral, gui = "bold" }, b = mid, c = tail },
                    command = { a = { fg = p.bg, bg = p.lavender, gui = "bold" }, b = mid, c = tail },
                    inactive = {
                        a = { bg = p.bg_alt, fg = p.fg_dim },
                        b = { bg = p.bg_alt, fg = p.fg_dim },
                        c = { bg = p.bg_alt, fg = p.fg_subtle },
                    },
                }
            end

            require("lualine").setup({
                options = {
                    theme = theme,
                    globalstatus = true,
                    section_separators = "",
                    component_separators = "",
                    disabled_filetypes = { statusline = { "snacks_dashboard" } },
                },
                sections = {
                    lualine_a = {
                        { "mode", fmt = function(s) return " " .. s:sub(1, 1) .. " " end, padding = 0 },
                    },
                    lualine_b = { { "branch", icon = "" } },
                    lualine_c = {
                        {
                            "filename",
                            path = 1,
                            symbols = { modified = " ●", readonly = "  ", newfile = "  " },
                        },
                    },
                    lualine_x = {
                        {
                            "diagnostics",
                            symbols = { error = " ", warn = " ", info = " ", hint = "󰌵 " },
                        },
                        { "diff", symbols = { added = "+", modified = "~", removed = "-" } },
                        {
                            function()
                                return (_G.ClaudeSidebar and _G.ClaudeSidebar.is_open()) and "󱙺" or ""
                            end,
                        },
                    },
                    lualine_y = {},
                    lualine_z = { { "location", padding = 1 } },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { "filename" },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = { "nvim-tree", "quickfix", "toggleterm", "lazy", "trouble" },
            })
        end,
    },

    -- barbar.nvim removed.
    --
    -- laststatus=3 exists to give one seamless global statusline; pinning a
    -- full-width tabline to row 1 undid exactly that. Harpoon (<M-1>..<M-4>)
    -- plus <leader><leader> is a better model anyway: name the four files that
    -- matter instead of scrolling everything you accidentally opened.
    -- lualine-lsp-progress went with it -- a spinner, percentage and client name
    -- is three moving elements for something you glance at twice a day.

    -- File explorer
    {
        "nvim-tree/nvim-tree.lua",
        keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file explorer" },
        },
        cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus" },
        config = function()
            require("nvim-tree").setup({
                hijack_netrw = false,
                disable_netrw = false,
                hijack_directories = { enable = false, auto_open = false },
                view = { width = 32, side = "left" },
                renderer = {
                    highlight_git = "name",
                    highlight_diagnostics = "name",
                    indent_markers = { enable = true },
                    icons = {
                        -- Inline diagnostic icons trigger E155 via sign_place;
                        -- filename highlighting via highlight_diagnostics still works.
                        show = { diagnostics = false },
                        glyphs = {
                            default = "󰈙",
                            symlink = "",
                            folder = {
                                arrow_closed = "",
                                arrow_open = "",
                                default = "",
                                open = "",
                                empty = "",
                                empty_open = "",
                                symlink = "",
                                symlink_open = "",
                            },
                            git = {
                                unstaged = "✗",
                                staged = "✓",
                                unmerged = "",
                                renamed = "➜",
                                untracked = "★",
                                deleted = "",
                                ignored = "◌",
                            },
                        },
                    },
                },
                update_focused_file = { enable = true },
                diagnostics = {
                    enable = true,
                    show_on_dirs = true,
                    icons = { hint = "󰌵", info = "", warning = "", error = "" },
                },
                filters = {
                    dotfiles = false,
                    custom = { "^.git$", "node_modules", "__pycache__" },
                },
                git = { enable = true, ignore = false },
                actions = { open_file = { quit_on_open = false, resize_window = true } },
            })
        end,
    },

    -- Which-key.
    --
    -- Only group definitions live here now. The ~120 `desc =` lines this block
    -- used to carry were duplicates: which-key reads descriptions straight off
    -- each `keys` entry and `vim.keymap.set` call, so maintaining them twice
    -- only guaranteed they would drift apart.
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            preset = "helix",
            delay = 300,
            -- Text only. which-key's default icon-per-mapping turns the popup
            -- into emoji soup; typographic reads as more deliberate.
            icons = { mappings = false, group = "" },
            win = { border = "rounded" },
            sort = { "local", "order", "group", "alphanum" },
            spec = {
                { "<leader>a", group = "AI (Claude)" },
                { "<leader>c", group = "Code" },
                { "<leader>d", group = "Debug" },
                { "<leader>f", group = "Find (Telescope)" },
                { "<leader>g", group = "Git" },
                { "<leader>h", group = "Harpoon" },
                { "<leader>j", group = "Split / Join" },
                { "<leader>l", group = "LSP" },
                { "<leader>m", group = "Markdown" },
                { "<leader>n", group = "Tests" },
                { "<leader>p", group = "Project / Session" },
                { "<leader>r", group = "Refactor" },
                { "<leader>s", group = "Search & Replace" },
                { "<leader>t", group = "Terminal" },
                { "<leader>x", group = "Diagnostics (Trouble)" },
                { "<leader>y", group = "Yank" },
                { "g", group = "Goto / LSP" },
            },
        },
    },

    -- nvim-notify and dressing.nvim removed: snacks.notifier and snacks.input
    -- replace them and inherit the NormalFloat/FloatBorder styling that
    -- colors/hack.lua already defines.
}
