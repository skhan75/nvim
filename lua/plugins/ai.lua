return {
    -- Avante: Cursor-like AI chat sidebar with inline diff accept/reject
    {
        "yetone/avante.nvim",
        branch = "main",
        build = "make",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "stevearc/dressing.nvim",
            "HakonHarnes/img-clip.nvim",
            "MeanderingProgrammer/render-markdown.nvim",
            "nvim-telescope/telescope.nvim",
        },
        event = "VeryLazy",
        config = function()
            require("avante").setup({
                -- Default AI provider (switch with <leader>as)
                provider = "claude",
                providers = {
                    claude = {
                        endpoint = "https://api.anthropic.com",
                        model = "claude-sonnet-4-20250514",
                        timeout = 30000,
                        extra_request_body = {
                            temperature = 0,
                            max_tokens = 16384,
                        },
                    },
                    openai = {
                        endpoint = "https://api.openai.com/v1",
                        model = "gpt-4o",
                        timeout = 30000,
                        extra_request_body = {
                            temperature = 0,
                            max_tokens = 16384,
                        },
                    },
                },
                behaviour = {
                    auto_focus_sidebar = true,
                    auto_suggestions = false,
                    auto_set_keymaps = true,
                    auto_add_current_file = true,
                    support_paste_from_clipboard = true,
                },
                -- Use Telescope for file/context selection (@ in sidebar opens Telescope)
                file_selector = {
                    provider = "telescope",
                    provider_opts = {},
                },
                -- Use Telescope for model/history selectors too
                selector = {
                    provider = "telescope",
                    provider_opts = {},
                },
                diff = {
                    autojump = true,
                },
                windows = {
                    width = 40,
                    sidebar_header = {
                        enabled = true,
                        align = "center",
                        rounded = false,
                    },
                    ask = {
                        floating = false,
                        start_insert = true,
                    },
                    selected_files = {
                        height = 4,
                    },
                },
                hints = { enabled = true },
                -- ─── Keymaps ─────────────────────────────────────────
                -- Global (work from any buffer):
                --   <leader>aa  Open AI chat
                --   <leader>ae  AI edit selection (visual)
                --   <leader>af  Focus sidebar
                --   <leader>at  Toggle sidebar
                --   <leader>ar  Refresh chat
                --   <leader>ac  Add current file to context
                --   <leader>aB  Add all open buffers to context
                --   <leader>a?  Select AI model
                --   <leader>aH  Browse chat history
                --
                -- Inside sidebar:
                --   @           Add file to context (opens Telescope)
                --   d           Remove file from context
                --   <Tab>       Switch between input / code / files
                --   a           Apply AI change at cursor
                --   A           Apply all AI changes
                --   e           Edit your last prompt
                --   r           Retry last request
                --   ]p / [p     Next / prev prompt in history
                --   q           Close sidebar
                --
                -- In code buffer (after AI suggests changes):
                --   co          Reject change (choose ours)
                --   ct          Accept change (choose theirs)
                --   ca          Accept all changes
                --   c0          Reject all changes
                --   ]x / [x     Jump between conflict markers
                mappings = {
                    ask = "<leader>aa",
                    edit = "<leader>ae",
                    refresh = "<leader>ar",
                    focus = "<leader>af",
                    stop = "<leader>aS",
                    toggle = {
                        default = "<leader>at",
                        debug = "<leader>ad",
                        hint = "<leader>aI",
                        suggestion = "<leader>al",
                        repomap = "<leader>aR",
                    },
                    files = {
                        add_current = "<leader>ac",
                        add_all_buffers = "<leader>aB",
                    },
                    select_model = "<leader>a?",
                    select_history = "<leader>aH",
                    sidebar = {
                        apply_all = "A",
                        apply_cursor = "a",
                        retry_user_request = "r",
                        edit_user_request = "e",
                        switch_windows = "<Tab>",
                        reverse_switch_windows = "<S-Tab>",
                        remove_file = "d",
                        add_file = "@",
                        close = { "q" },
                    },
                },
            })

            -- Provider switching command: :AvanteProvider claude / :AvanteProvider openai
            vim.api.nvim_create_user_command("AvanteProvider", function(opts)
                local provider = opts.args
                if provider == "claude" or provider == "openai" then
                    require("avante.config").override({ provider = provider })
                    vim.notify("AI Provider: " .. provider, vim.log.levels.INFO)
                else
                    vim.notify("Usage: :AvanteProvider claude|openai", vim.log.levels.WARN)
                end
            end, {
                nargs = 1,
                complete = function()
                    return { "claude", "openai" }
                end,
                desc = "Switch Avante AI provider",
            })
        end,
    },

    -- Render Markdown nicely in Avante sidebar
    {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "Avante" },
        opts = {
            file_types = { "markdown", "Avante" },
        },
    },
}
