return {
    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            "nvim-telescope/telescope-file-browser.nvim",
            "nvim-telescope/telescope-project.nvim",
            -- telescope-media-files removed: unmaintained since Feb 2023, it
            -- shells out to ueberzug/chafa (neither installed), and it cannot
            -- render images under WSL2 anyway.
        },
        cmd = "Telescope",
        keys = {
            -- File & text searching
            { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Search text in files" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "List open buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Search help tags" },
            { "<leader>fB", "<cmd>Telescope file_browser<cr>", desc = "Open file browser" },
            -- Grep the word under the cursor / the visual selection. Removes a
            -- yank-then-paste-into-the-prompt round trip done many times a day.
            { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "Grep word under cursor" },
            { "<leader>fw", "<cmd>Telescope grep_string<cr>", mode = "x", desc = "Grep selection" },
            { "<leader>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace symbols" },
            { "<leader>f'", "<cmd>Telescope marks<cr>", desc = "Marks" },
            { "<leader>fp", "<cmd>Telescope project<cr>", desc = "Search projects" },
            { "<leader>fo", "<cmd>Telescope oldfiles<cr>", desc = "Recently opened files" },
            { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Show key mappings" },
            { "<leader>fq", "<cmd>Telescope quickfix<cr>", desc = "Show quickfix list" },
            { "<leader>fl", "<cmd>Telescope loclist<cr>", desc = "Show location list" },
            { "<leader>fc", "<cmd>Telescope find_files cwd=~/.config/nvim<cr>", desc = "Search nvim config" },
            { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Show diagnostics" },
            { "<leader>fr", "<cmd>Telescope lsp_references<cr>", desc = "Show LSP references" },
            { "<leader>fH", "<cmd>Telescope command_history<cr>", desc = "Show command history" },
            { "<leader>fR", "<cmd>Telescope registers<cr>", desc = "Show registers" },
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
            local actions = require("telescope.actions")

            -- Pick the fastest file lister that actually exists on this machine.
            -- `fd` was hardcoded, but it is not installed here (Debian/Ubuntu
            -- ship it as `fdfind`), which made <leader>ff fail outright.
            -- Returning nil lets Telescope fall back to its own default.
            local function find_command()
                local excludes = { "--exclude=.git", "--exclude=node_modules" }
                for _, bin in ipairs({ "fd", "fdfind" }) do
                    if vim.fn.executable(bin) == 1 then
                        return vim.list_extend(
                            { bin, "--type=f", "--hidden", "--strip-cwd-prefix" },
                            excludes
                        )
                    end
                end
                if vim.fn.executable("rg") == 1 then
                    return {
                        "rg", "--files", "--hidden",
                        "--glob=!**/.git/*", "--glob=!**/node_modules/*",
                    }
                end
                return nil
            end

            telescope.setup({
                defaults = {
                    -- Use ripgrep for live_grep, including hidden files but skipping .git
                    vimgrep_arguments = {
                        "rg", "--color=never", "--no-heading", "--with-filename",
                        "--line-number", "--column", "--smart-case",
                        "--hidden", "--glob=!**/.git/*",
                    },
                    prompt_prefix = "  ",
                    selection_caret = " ",
                    entry_prefix = "  ",
                    initial_mode = "insert",
                    selection_strategy = "reset",
                    -- Ascending + top prompt = modern layout, easier to scan
                    sorting_strategy = "ascending",
                    layout_strategy = "horizontal",
                    layout_config = {
                        prompt_position = "top",
                        horizontal = { preview_width = 0.55, results_width = 0.8 },
                        vertical = { mirror = false },
                        width = 0.87,
                        height = 0.80,
                        preview_cutoff = 120,
                    },
                    path_display = { "truncate" },
                    -- Skip heavy directories on every search
                    file_ignore_patterns = {
                        "%.git/", "node_modules/", "dist/", "build/", "target/",
                        "%.next/", "%.cache/", "__pycache__/", "%.venv/", "venv/",
                        "%.lock", "%.min%.js", "%.min%.css", "%.map",
                        "%.png", "%.jpg", "%.jpeg", "%.gif", "%.webp", "%.ico",
                        "%.pdf", "%.zip", "%.tar%.gz",
                    },
                    border = {},
                    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
                    color_devicons = true,
                    set_env = { ["COLORTERM"] = "truecolor" },
                    -- Cache previews for snappier scrolling through results
                    cache_picker = { num_pickers = 5 },
                    mappings = {
                        i = {
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                            ["<C-d>"] = actions.preview_scrolling_down,
                            ["<C-u>"] = actions.preview_scrolling_up,
                            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                            ["<C-a>"] = actions.send_to_qflist + actions.open_qflist,
                            ["<C-x>"] = actions.select_horizontal,
                            ["<C-v>"] = actions.select_vertical,
                            ["<C-t>"] = actions.select_tab,
                            ["<Esc>"] = actions.close,
                        },
                        n = {
                            ["q"] = actions.close,
                            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                        },
                    },
                },
                pickers = {
                    -- Fastest available lister (fd → fdfind → rg → built-in)
                    find_files = {
                        find_command = find_command(),
                    },
                    buffers = {
                        sort_lastused = true,
                        sort_mru = true,
                        ignore_current_buffer = true,
                        mappings = {
                            i = { ["<C-d>"] = actions.delete_buffer },
                            n = { ["dd"] = actions.delete_buffer },
                        },
                    },
                    live_grep = { additional_args = function() return { "--hidden" } end },
                    lsp_references = { show_line = false, include_declaration = false },
                },
                extensions = {
                    fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = "smart_case",
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
            telescope.load_extension("file_browser")
            telescope.load_extension("project")
        end,
    },
}
