return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            "nvim-telescope/telescope-media-files.nvim",
            "nvim-telescope/telescope-file-browser.nvim",
            "nvim-telescope/telescope-project.nvim",
        },
        cmd = "Telescope",
        keys = {
            -- File & text searching
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Search text in files" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "List open buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Search help tags" },
            { "<leader>fm", "<cmd>Telescope media_files<cr>", desc = "Search media files" },
            { "<leader>fbr", "<cmd>Telescope file_browser<cr>", desc = "Open file browser" },
            { "<leader>fp", "<cmd>Telescope project<cr>", desc = "Search projects" },
            { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Recently opened files" },
            { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Show key mappings" },
            { "<leader>fq", "<cmd>Telescope quickfix<cr>", desc = "Show quickfix list" },
            { "<leader>fl", "<cmd>Telescope loclist<cr>", desc = "Show location list" },
            { "<leader>fc", "<cmd>Telescope find_files cwd=~/.config/nvim<cr>", desc = "Search nvim config" },
            { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Show diagnostics" },
            { "<leader>fr", "<cmd>Telescope lsp_references<cr>", desc = "Show LSP references" },
            { "<leader>fhc", "<cmd>Telescope command_history<cr>", desc = "Show command history" },
            { "<leader>frg", "<cmd>Telescope registers<cr>", desc = "Show registers" },
            -- Git (via Telescope)
            { "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git status" },
            { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git branches" },
            { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
            { "<leader>gf", "<cmd>Telescope git_files<cr>", desc = "Git tracked files" },
            -- LSP symbols
            { "<leader>ld", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
        },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                defaults = {
                    vimgrep_arguments = {
                        "rg", "--color=never", "--no-heading", "--with-filename",
                        "--line-number", "--column", "--smart-case",
                    },
                    prompt_prefix = "> ",
                    selection_caret = "> ",
                    entry_prefix = "  ",
                    initial_mode = "insert",
                    selection_strategy = "reset",
                    sorting_strategy = "descending",
                    layout_strategy = "horizontal",
                    layout_config = {
                        horizontal = { mirror = false },
                        vertical = { mirror = false },
                    },
                    path_display = { "truncate" },
                    border = {},
                    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                    color_devicons = true,
                    set_env = { ["COLORTERM"] = "truecolor" },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
                    },
                    media_files = {
                        filetypes = { "png", "jpg", "mp4", "webm", "pdf" },
                        find_cmd = "rg",
                    },
                    project = {
                        base_dirs = { "~/workspace" },
                        hidden_files = true,
                        theme = "dropdown",
                        order_by = "asc",
                        sync_with_nvim_tree = true,
                    },
                },
            })
            telescope.load_extension("fzf")
            telescope.load_extension("media_files")
            telescope.load_extension("file_browser")
            telescope.load_extension("project")
        end,
    },
}
