-- Enable byte-code caching for faster startup (replaces impatient.nvim, built-in since Neovim 0.9+)
vim.loader.enable()

-- Set leader key BEFORE any plugins or keymaps load
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core configuration
require("config.options")

-- Plugin manager (lazy.nvim) - loads all plugin specs from lua/plugins/
require("config.lazy")

-- Keymaps (loaded after plugins so which-key can detect them)
require("config.keymaps")
