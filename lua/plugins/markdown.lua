-- Markdown.
--
-- Removed three of the five plugins that were here:
--   plasticboy/vim-markdown -- Vimscript regex syntax plus its own foldexpr,
--     both of which fight the treesitter markdown parser and render-markdown.
--     The repo also moved to preservim years ago.
--   preservim/vim-pencil -- unmaintained since 2023; its "soft wrap" mode is
--     wrap + linebreak + breakindent + nolist, now a FileType autocmd in
--     config/options.lua.
--   ellisonleao/glow.nvim -- the `glow` binary is not installed, so :Glow was
--     a dead command.
return {
    -- Markdown preview in the browser.
    -- Note: if :MarkdownPreview fails, run `:Lazy build markdown-preview.nvim`
    -- -- the build step had never completed.
    {
        "iamcco/markdown-preview.nvim",
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
        ft = "markdown",
        keys = {
            { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "Toggle markdown preview" },
        },
    },

    -- In-buffer rendering -- this is the one that renders .md *inside* nvim
    -- rather than shelling out to a browser. conceallevel is set to 3 for
    -- markdown in config/options.lua; the previous global conceallevel=0 meant
    -- this plugin could only ever do half its job.
    --
    -- Requires the `markdown` and `markdown_inline` treesitter parsers. They
    -- are in the wanted list in plugins/editor.lua, but that list only installs
    -- what is missing at startup -- if rendering ever looks inert, check
    -- `:checkhealth render-markdown` before touching this config.
    {
        "MeanderingProgrammer/render-markdown.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.icons" },
        ft = { "markdown", "markdown_inline" },
        opts = {
            file_types = { "markdown" },
            completions = { blink = { enabled = true } },

            -- Reveal the raw source of whatever line the cursor is on. Without
            -- this, editing a heading or a link means editing characters you
            -- cannot see.
            anti_conceal = { enabled = true },

            -- Off deliberately: neither `utftex` nor `latex2text` is installed
            -- and there is no latex parser, so leaving this on only produced
            -- three checkhealth warnings and work that could never render.
            latex = { enabled = false },

            heading = {
                -- The icon already marks the level; a sign column glyph on top
                -- of it is the same information twice.
                sign = false,
                position = "inline",
                icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
                -- 'block' stops the tint at the end of the heading text.
                -- 'full' (the default) paints it to the window edge, which
                -- turns every H1 into a banner.
                width = "block",
                left_pad = 0,
                right_pad = 2,
                min_width = 20,
            },

            code = {
                sign = false,
                style = "full",
                width = "block",
                left_pad = 2,
                right_pad = 2,
                min_width = 40,
                -- 'thin' draws the fence as a rule instead of leaving the
                -- ``` delimiters visible.
                border = "thin",
                language_pad = 2,
            },

            bullet = { icons = { "●", "○", "◆", "◇" } },

            checkbox = {
                unchecked = { icon = "󰄱 " },
                checked = { icon = "󰱒 " },
                custom = {
                    todo = { raw = "[~]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
                    blocked = { raw = "[!]", rendered = "󰀦 ", highlight = "DiagnosticWarn" },
                },
            },

            quote = { icon = "▎" },
            dash = { icon = "─" },
            pipe_table = { style = "full", preset = "round" },

            link = {
                image = "󰥶 ",
                email = "󰇮 ",
                hyperlink = "󰌷 ",
                wiki = { icon = "󱗖 " },
            },
        },
        keys = {
            -- Rendered view is the default; toggle back to raw markdown when
            -- you need to see the literal syntax.
            { "<leader>mr", "<cmd>RenderMarkdown buf_toggle<cr>", ft = "markdown", desc = "Toggle rendering (buffer)" },
            { "<leader>me", "<cmd>RenderMarkdown expand<cr>",     ft = "markdown", desc = "Expand rendering" },
            { "<leader>mc", "<cmd>RenderMarkdown contract<cr>",   ft = "markdown", desc = "Contract rendering" },
        },
    },
}
