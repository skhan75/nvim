return {
    -- Treesitter: parsers AND highlighting.
    --
    -- The `main` branch (which lazy-lock pins) removed the automatic
    -- highlight/indent/fold modules that the old `master` branch provided via
    -- `configs.setup{}`. The previous config installed parsers and stopped
    -- there, so every language except Lua fell back to Vim's regex syntax
    -- engine -- verified: typescript/python/go all had ts_highlight=false while
    -- their parsers sat on disk unused. That also made the ~124 @-capture
    -- groups in colors/hack.lua dead code for those languages.
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
        lazy = false, -- the FileType autocmd must exist before the first file
        config = function()
            local wanted = {
                "c", "cpp", "lua", "java", "python", "javascript", "go",
                "markdown", "markdown_inline", "json", "yaml", "toml",
                "vim", "vimdoc", "typescript", "tsx", "elixir", "heex", "eex",
                "html", "css", "bash", "regex", "diff", "query", "gitcommit",
            }
            local installed = require("nvim-treesitter.config").get_installed()
            local to_install = vim.tbl_filter(function(lang)
                return not vim.tbl_contains(installed, lang)
            end, wanted)
            if #to_install > 0 then
                require("nvim-treesitter.install").install(to_install)
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
                callback = function(ev)
                    local lang = vim.treesitter.language.get_lang(ev.match)
                    if not lang then return end
                    if not pcall(vim.treesitter.language.add, lang) then return end
                    pcall(vim.treesitter.start, ev.buf, lang)
                    -- Retire the regex engine for this buffer.
                    vim.bo[ev.buf].syntax = ""
                end,
            })
        end,
    },

    -- Structural textobjects: af/if (function), ac/ic (class), aa/ia (argument),
    -- plus ]f/[f motions and g>/g< parameter swaps. The config previously had no
    -- structural textobjects at all, so "select this function" meant counting lines.
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("nvim-treesitter-textobjects").setup({
                select = { lookahead = true, include_surrounding_whitespace = false },
                move = { set_jumps = true },
            })

            local sel = require("nvim-treesitter-textobjects.select")
            local move = require("nvim-treesitter-textobjects.move")
            local swap = require("nvim-treesitter-textobjects.swap")

            -- a/i selection pairs. `c` is class; git hunks keep ]c/[c.
            local objects = {
                f = "function", c = "class", a = "parameter", o = "loop",
                n = "conditional", k = "call", g = "comment", r = "return",
            }
            for key, obj in pairs(objects) do
                vim.keymap.set({ "x", "o" }, "a" .. key, function()
                    sel.select_textobject("@" .. obj .. ".outer", "textobjects")
                end, { desc = "outer " .. obj })
                vim.keymap.set({ "x", "o" }, "i" .. key, function()
                    sel.select_textobject("@" .. obj .. ".inner", "textobjects")
                end, { desc = "inner " .. obj })
            end

            local motions = {
                ["]f"] = { move.goto_next_start, "@function.outer" },
                ["[f"] = { move.goto_previous_start, "@function.outer" },
                ["]F"] = { move.goto_next_end, "@function.outer" },
                ["[F"] = { move.goto_previous_end, "@function.outer" },
                ["]t"] = { move.goto_next_start, "@class.outer" },
                ["[t"] = { move.goto_previous_start, "@class.outer" },
                ["]a"] = { move.goto_next_start, "@parameter.inner" },
                ["[a"] = { move.goto_previous_start, "@parameter.inner" },
            }
            for lhs, spec in pairs(motions) do
                vim.keymap.set({ "n", "x", "o" }, lhs, function()
                    spec[1](spec[2], "textobjects")
                end, { desc = "goto " .. spec[2] })
            end

            vim.keymap.set("n", "g>", function()
                swap.swap_next("@parameter.inner")
            end, { desc = "Swap parameter right" })
            vim.keymap.set("n", "g<", function()
                swap.swap_previous("@parameter.inner")
            end, { desc = "Swap parameter left" })
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
                opts = {
                    enable_close = true,
                    enable_rename = true,
                    enable_close_on_slash = false,
                },
            })
        end,
    },

    -- Comment.nvim removed: Neovim ships gc/gcc/gbc/gcO/gco/gcA natively via
    -- vim._comment, and the plugin was last updated in June 2024. Identical
    -- keys, one fewer BufReadPost dependency.

    -- Surround text objects
    {
        "kylechui/nvim-surround",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup()
        end,
    },

    -- Flash: replaces leap.nvim. Keeps the same s/S keys, but also upgrades
    -- f/t/F/T/;/, to multi-line with labels, adds treesitter node selection, and
    -- adds the remote operator (yr<jump><textobject> yanks a distant function and
    -- returns the cursor). leap was also declared mode="n" only here, so `ds<char>`
    -- and `vs<char>` -- half of what it's for -- silently did nothing.
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {
            modes = {
                char = { jump_labels = true },
                search = { enabled = false }, -- opt in with <C-s> while searching
            },
            jump = { nohlsearch = true },
        },
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
            { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
            { "r", mode = "o", function() require("flash").remote() end, desc = "Remote flash" },
            { "R", mode = "o", function() require("flash").treesitter_search() end, desc = "Treesitter search" },
            { "<C-s>", mode = "c", function() require("flash").toggle() end, desc = "Toggle flash search" },
        },
    },

    -- Split and Join code blocks.
    -- Moved off <leader>t*, which was shared with the terminal group purely
    -- because both words start with "t".
    {
        "Wansmer/treesj",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        keys = {
            { "<leader>js", "<cmd>TSJSplit<cr>", desc = "Split block into multiple lines" },
            { "<leader>jj", "<cmd>TSJJoin<cr>", desc = "Join block into one line" },
        },
        config = function()
            require("treesj").setup({})
        end,
    },

    -- Todo comments highlighting
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        config = function()
            require("todo-comments").setup({
                -- hack.lua already backlights @comment.todo; keep this to
                -- foreground + signs so the two don't stack.
                highlight = { keyword = "wide_fg" },
            })
        end,
    },

    -- indent-blankline removed: snacks.indent (lua/plugins/snacks.lua) does the
    -- same job with extmarks, renders only the viewport, and needs no
    -- hand-maintained filetype exclusion list.
}
