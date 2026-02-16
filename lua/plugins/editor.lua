return {
    -- Treesitter: parser management (highlighting/indent are built into Neovim 0.10+)
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local wanted = {
                "c", "cpp", "lua", "java", "python", "javascript", "go",
                "markdown", "json", "yaml", "vim", "typescript",
                "elixir", "heex", "eex",
            }
            local installed = require("nvim-treesitter.config").get_installed()
            local to_install = vim.tbl_filter(function(lang)
                return not vim.tbl_contains(installed, lang)
            end, wanted)
            if #to_install > 0 then
                require("nvim-treesitter.install").install(to_install)
            end
        end,
    },

    -- Autopairs: automatic closing of brackets
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({
                check_ts = true,
                disable_filetype = { "TelescopePrompt", "vim" },
            })
        end,
    },

    -- Auto close/rename HTML tags
    {
        "windwp/nvim-ts-autotag",
        event = "InsertEnter",
        config = function()
            require("nvim-ts-autotag").setup({
                filetypes = { "html", "javascript", "typescriptreact", "vue" },
            })
        end,
    },

    -- Comment toggling
    {
        "numToStr/Comment.nvim",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("Comment").setup()
        end,
    },

    -- Surround text objects
    {
        "kylechui/nvim-surround",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-surround").setup()
        end,
    },

    -- Leap: quick motion
    {
        "ggandor/leap.nvim",
        keys = {
            { "s", "<Plug>(leap-forward-to)", desc = "Leap forward", mode = "n" },
            { "S", "<Plug>(leap-backward-to)", desc = "Leap backward", mode = "n" },
        },
        config = function()
            require("leap").setup({})
        end,
    },

    -- Split and Join code blocks
    {
        "Wansmer/treesj",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        keys = {
            { "<leader>ts", "<cmd>TSJSplit<cr>", desc = "Split block into multiple lines" },
            { "<leader>tj", "<cmd>TSJJoin<cr>", desc = "Join block into one line" },
        },
        config = function()
            require("treesj").setup({})
        end,
    },

    -- Todo comments highlighting
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("todo-comments").setup({})
        end,
    },

    -- Indent guides (vertical lines at indent levels)
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            local hooks = require("ibl.hooks")
            hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
                vim.api.nvim_set_hl(0, "IblIndent", { fg = "#3b3b3b", nocombine = true })
                vim.api.nvim_set_hl(0, "IblScope", { fg = "#5b5b5b", nocombine = true })
            end)
            require("ibl").setup({
                indent = { char = "│", tab_char = "│", highlight = { "IblIndent" } },
                scope = { enabled = true, show_start = false, show_end = false, highlight = { "IblScope" } },
                exclude = {
                    filetypes = {
                        "help", "alpha", "dashboard", "NvimTree", "Trouble",
                        "lazy", "mason", "notify", "toggleterm", "Avante",
                    },
                },
            })
        end,
    },
}
