-- Mirrors your Zed settings.json where an editor equivalent exists.
local opt = vim.opt

opt.number = true
opt.relativenumber = true          -- Zed: "relative_line_numbers": "enabled"
opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20"  -- no blink (Zed: cursor_blink: false)

opt.mouse = "a"
opt.clipboard = "unnamedplus"       -- share yank with system clipboard
opt.termguicolors = true            -- true-color for Dracula

opt.ignorecase = true
opt.smartcase = true
opt.wrap = false

opt.expandtab = true                -- spaces, matches prettier defaults
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

opt.signcolumn = "yes"              -- stable gutter for git/diagnostic signs
opt.cursorline = true
opt.scrolloff = 8
opt.splitright = true               -- :vsplit opens to the right (space s v)
opt.splitbelow = true               -- :split opens below (space s s)

opt.undofile = true                 -- persistent undo
opt.swapfile = false
opt.updatetime = 250

-- Zed "autosave": "on_focus_change" -> save when leaving a buffer/window.
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
  pattern = "*",
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! write")
    end
  end,
})

-- Highlight yanked text briefly.
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})
