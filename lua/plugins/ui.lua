return {
    -- Icons
    { "nvim-tree/nvim-web-devicons", lazy = true },
    { "echasnovski/mini.icons", version = "*", lazy = true },

    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "arkav/lualine-lsp-progress",
        },
        event = "VeryLazy",
        config = function()
            require("lualine").setup({
                options = {
                    theme = "cyberdream",
                    globalstatus = true,
                    section_separators = { left = "", right = "" },
                    component_separators = { left = "", right = "" },
                },
                sections = {
                    lualine_a = { { "mode", separator = { left = "", right = "" } } },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = {
                        { "filename", file_status = true, path = 1 },
                        {
                            "lsp_progress",
                            display_components = { "lsp_client_name", "spinner", "percentage" },
                        },
                    },
                    lualine_x = {
                        {
                            function()
                                local open = _G.ClaudeSidebar and _G.ClaudeSidebar.is_open()
                                return open and "󱙺 Claude" or ""
                            end,
                            cond = function()
                                return _G.ClaudeSidebar ~= nil and _G.ClaudeSidebar.is_open()
                            end,
                        },
                        "encoding",
                        "fileformat",
                        "filetype",
                    },
                    lualine_y = { "progress" },
                    lualine_z = { { "location", separator = { left = "", right = "" } } },
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { "filename" },
                    lualine_x = { "location" },
                    lualine_y = {},
                    lualine_z = {},
                },
                extensions = { "nvim-tree", "quickfix", "toggleterm", "lazy" },
            })
        end,
    },

    -- Buffer tabs
    {
        "romgrk/barbar.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        keys = {
            { "[b", ":BufferPrevious<CR>", desc = "Previous buffer", silent = true },
            { "]b", ":BufferNext<CR>", desc = "Next buffer", silent = true },
            { "<leader>b1", ":BufferGoto 1<CR>", desc = "Go to buffer 1", silent = true },
            { "<leader>b2", ":BufferGoto 2<CR>", desc = "Go to buffer 2", silent = true },
            { "<leader>b3", ":BufferGoto 3<CR>", desc = "Go to buffer 3", silent = true },
            { "<leader>b4", ":BufferGoto 4<CR>", desc = "Go to buffer 4", silent = true },
            { "<leader>b5", ":BufferGoto 5<CR>", desc = "Go to buffer 5", silent = true },
            { "<leader>b6", ":BufferGoto 6<CR>", desc = "Go to buffer 6", silent = true },
            { "<leader>b7", ":BufferGoto 7<CR>", desc = "Go to buffer 7", silent = true },
            { "<leader>b8", ":BufferGoto 8<CR>", desc = "Go to buffer 8", silent = true },
            { "<leader>b9", ":BufferGoto 9<CR>", desc = "Go to buffer 9", silent = true },
            { "<leader>bc", ":BufferClose<CR>", desc = "Close current buffer", silent = true },
            { "<leader>bp", ":BufferPick<CR>", desc = "Pick a buffer", silent = true },
            { "<leader>br", ":BufferMoveNext<CR>", desc = "Move buffer right", silent = true },
            { "<leader>bl", ":BufferMovePrevious<CR>", desc = "Move buffer left", silent = true },
        },
    },

    -- File explorer
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        keys = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file explorer" },
        },
        cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus" },
        config = function()
            require("nvim-tree").setup({
                hijack_netrw = false,
                disable_netrw = false,
                hijack_directories = { enable = false, auto_open = false },
                view = {
                    width = 32,
                    side = "left",
                },
                renderer = {
                    highlight_git = "name",
                    highlight_diagnostics = "name",
                    indent_markers = { enable = true },
                    icons = {
                        -- Disable inline diagnostic icons in the tree;
                        -- their signcolumn placement triggers E155 errors.
                        -- Filename highlight via highlight_diagnostics still works.
                        show = {
                            diagnostics = false,
                        },
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
                actions = {
                    open_file = { quit_on_open = false, resize_window = true },
                },
            })
        end,
    },

    -- Which-key: shows pending keybindings
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            local wk = require("which-key")
            wk.setup({
                icons = { group = " " },
            })
            wk.add({
                -- ─── Leader prefix groups ─────────────────────────────
                { "<leader>a",  group = "AI (Claude)",       icon = "󱙺 " },
                { "<leader>aa", desc = "Toggle Claude sidebar" },
                { "<leader>af", desc = "Focus Claude sidebar" },
                { "<leader>at", desc = "Toggle Claude sidebar" },
                { "<leader>aq", desc = "Close Claude sidebar" },

                { "<leader>b",  group = "Buffers",          icon = " " },
                { "<leader>bc", desc = "Close current buffer" },
                { "<leader>bp", desc = "Pick a buffer" },
                { "<leader>br", desc = "Move buffer right" },
                { "<leader>bl", desc = "Move buffer left" },

                { "<leader>c",  group = "Code",             icon = " " },
                { "<leader>ca", desc = "Code actions" },
                { "<leader>co", desc = "Toggle code outline" },

                { "<leader>d",  group = "Delete",           icon = " " },
                { "<leader>da", desc = "Delete entire file contents" },

                { "<leader>f",  group = "Find (Telescope)", icon = " " },
                { "<leader>ff", desc = "Find files" },
                { "<leader>fg", desc = "Search text (grep)" },
                { "<leader>fb", desc = "List open buffers" },
                { "<leader>fh", desc = "Search help tags" },
                { "<leader>fm", desc = "Search media files" },
                { "<leader>fo", desc = "Recently opened files" },
                { "<leader>fk", desc = "Show all key mappings" },
                { "<leader>fq", desc = "Show quickfix list" },
                { "<leader>fl", desc = "Show location list" },
                { "<leader>fc", desc = "Search nvim config files" },
                { "<leader>fd", desc = "Show diagnostics" },
                { "<leader>fr", desc = "Show LSP references" },
                { "<leader>fp", desc = "Search projects" },
                { "<leader>fB", desc = "Open file browser" },
                { "<leader>fH", desc = "Show command history" },
                { "<leader>fR", desc = "Show registers" },

                { "<leader>g",  group = "Git / Diff review", icon = " " },
                { "<leader>gs", desc = "Git status" },
                { "<leader>gb", desc = "Git branches" },
                { "<leader>gc", desc = "Git commits" },
                { "<leader>gf", desc = "Git tracked files" },
                { "<leader>gD", desc = "Review all changes (diff view)" },
                { "<leader>gH", desc = "File history (current file)" },
                { "<leader>gQ", desc = "Close diff view" },
                { "<leader>gm", desc = "List modified files (quickfix)" },
                { "<leader>gp", desc = "Preview hunk" },
                { "<leader>gi", desc = "Preview hunk inline" },
                { "<leader>gsh", desc = "Stage hunk" },
                { "<leader>guh", desc = "Reset hunk (undo)" },
                { "<leader>gS", desc = "Stage entire buffer" },
                { "<leader>gr", desc = "Reset entire buffer" },
                { "<leader>gB", desc = "Toggle line blame" },
                { "<leader>gd", desc = "Toggle deleted lines" },
                { "<leader>gw", desc = "Toggle word diff" },
                { "<leader>gl", desc = "Toggle git line highlights" },
                { "<leader>gbl", desc = "Blame current line" },

                { "<leader>h",  group = "Harpoon",          icon = "󰛢 " },
                { "<leader>ha", desc = "Add file to Harpoon" },
                { "<leader>hh", desc = "Toggle Harpoon menu" },
                { "<leader>hc", desc = "Clear search highlights" },

                { "<leader>l",  group = "LSP",              icon = " " },
                { "<leader>ld", desc = "Document symbols" },
                { "<leader>le", desc = "Show line diagnostic (popup)" },
                { "<leader>lL", desc = "Toggle diagnostic display mode" },

                { "<leader>r",  group = "Refactor",         icon = " " },
                { "<leader>rn", desc = "Rename symbol" },

                { "<leader>t",  group = "Terminal / Treesj", icon = " " },
                { "<leader>tt", desc = "Toggle terminal" },
                { "<leader>ts", desc = "Split block into lines" },
                { "<leader>tj", desc = "Join block into one line" },

                { "<leader>y",  group = "Yank",             icon = " " },
                { "<leader>ya", desc = "Yank entire file" },

                -- ─── Standalone leader keys ───────────────────────────
                { "<leader>e",  desc = "Toggle file explorer" },
                { "<leader>w",  desc = "Save file" },
                { "<leader>q",  desc = "Quit" },
                { "<leader>x",  desc = "Dismiss notifications" },

                -- ─── Non-leader keys (for reference) ─────────────────
                { "g",          group = "Go to / LSP" },
                { "gd",         desc = "Go to definition" },
                { "gr",         desc = "Show references" },
                { "gi",         desc = "Go to implementation" },
                { "gk",         desc = "Hover documentation" },

                { "[b",         desc = "Previous buffer" },
                { "]b",         desc = "Next buffer" },
                { "[c",         desc = "Prev git change" },
                { "]c",         desc = "Next git change" },
                { "[q",         desc = "Prev quickfix item" },
                { "]q",         desc = "Next quickfix item" },
                { "s",          desc = "Leap forward" },
                { "S",          desc = "Leap backward" },

                -- ─── Ctrl shortcuts ──────────────────────────────────
                { "<C-l>",      desc = "AI: Toggle Claude sidebar" },
                { "<C-\\>",     desc = "Toggle terminal" },
            })
        end,
    },

    -- Notifications
    {
        "rcarriga/nvim-notify",
        event = "VeryLazy",
        keys = {
            {
                "<leader>x",
                function() require("notify").dismiss() end,
                desc = "Close all notifications",
            },
        },
        config = function()
            require("notify").setup({
                background_colour = "#000000",
                render = "wrapped-compact",
                stages = "fade_in_slide_out",
                timeout = 3000,
                max_width = 60,
                top_down = true,
            })
            vim.notify = require("notify")
        end,
    },

    -- Better UI for select/input dialogs
    { "stevearc/dressing.nvim", event = "VeryLazy" },
}
