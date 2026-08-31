-- In-buffer markdown rendering: styled headers, iconified bullets/checkboxes,
-- boxed code fences, concealed **bold**/*italic* markup -- the closest thing to
-- Obsidian's "reading mode" without leaving Neovim. Uses the markdown/
-- markdown_inline treesitter parsers already installed by plugins/treesitter.lua.
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  -- anti_conceal off: keep markup hidden on the cursor line too
  opts = { anti_conceal = { enabled = false } },
  keys = {
    { "<leader>mp", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle markdown render" },
  },
}
