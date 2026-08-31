-- Neovim config generated from Pasin's Zed usage.
-- Leader must be set before lazy.nvim loads so plugin keymaps register correctly.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options")
require("config.lazy")
require("config.keymaps")
