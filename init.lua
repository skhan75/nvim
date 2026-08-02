-- Enable byte-code caching for faster startup (replaces impatient.nvim, built-in since Neovim 0.9+)
vim.loader.enable()

-- Set leader key BEFORE any plugins or keymaps load
vim.g.mapleader = " "
-- localleader must differ from leader: plugins bind <localleader>x inside their
-- own buffers (grug-far uses <localleader>r), which would collide with <leader>r.
vim.g.maplocalleader = ","

-- Shims for APIs this Neovim build advertises but does not ship.
-- Must load before anything feature-detects on the version string.
require("config.compat")

-- Core configuration
require("config.options")

-- Colorscheme. `hack` is local (colors/hack.lua), so it needs no plugin and no
-- download -- cyberdream.nvim used to be installed purely to source a lualine
-- theme, which lualine now builds from _G.HackPalette directly.
vim.cmd.colorscheme("hack")

-- Plugin manager (lazy.nvim) - loads all plugin specs from lua/plugins/
require("config.lazy")

-- Keymaps (loaded after plugins so which-key can detect them)
require("config.keymaps")
