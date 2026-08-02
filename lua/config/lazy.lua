-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
    -- Lazy by default. Specs that genuinely need eager loading say so
    -- explicitly (treesitter, snacks, blink). Previously this was `false`, which
    -- meant any new spec without a keys/cmd/ft/event trigger silently became an
    -- eager load and lazy.nvim's own profiling couldn't flag it.
    defaults = { lazy = true },
    install = { colorscheme = { "hack" } },
    checker = { enabled = false },
    change_detection = { notify = false },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
