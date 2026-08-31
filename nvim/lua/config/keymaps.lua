-- Non-plugin keymaps. Plugin-specific maps live next to their plugin spec.
-- Every binding here traces directly to your Zed keymap.json.
local map = vim.keymap.set

-- Buffer navigation (Zed: shift-l / shift-h + space b n / space b p)
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Prev buffer" })

-- Splits (Zed: space s v / space s s)
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split right" })
map("n", "<leader>ss", "<cmd>split<cr>", { desc = "Split down" })

-- Window/pane navigation (Zed: ctrl-h/j/k/l)
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })

-- File ops (Zed: space w save, space q close, space f n new file)
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })

-- Undo. Native undo is `u`. Map <C-z> too (Zed muscle memory) — in a terminal
-- <C-z> normally suspends Neovim, so this reclaims it for undo in normal+insert.
map("n", "<C-z>", "u", { desc = "Undo" })
map("i", "<C-z>", "<C-o>u", { desc = "Undo" })
-- Redo stays on native <C-r> (normal mode).

-- Esc clears search highlight (so you don't have to type :noh)
map("n", "<Esc>", "<cmd>nohlsearch <bar> echon ''<cr>", { desc = "Clear search highlight + message line" })

-- ctrl-o / ctrl-i (jump list) are native in Neovim — nothing to map.
