-- Panels, git, terminal, comments — the "dock" side of your Zed layout.
return {
  -- File explorer (Zed: space e project panel; space h/l dock toggles)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle filesystem left<cr>", desc = "Explorer" },       -- Zed: space e
      { "<leader>h", "<cmd>Neotree toggle git_status left<cr>", desc = "Git tree (left dock)" }, -- Zed: space h
      { "<leader>l", "<cmd>Neotree toggle filesystem right<cr>", desc = "Explorer (right dock)" }, -- Zed: space l
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,        -- show hidden/dotfiles/gitignored by default
          hide_dotfiles = false,
          hide_gitignored = false,
          -- never_show wins over visible=true: these are hidden AND never
          -- scanned/watched. Critical here — these projects aren't git repos,
          -- so hide_gitignored can't filter node_modules; expanding a folder
          -- would otherwise read + libuv-watch ~70k dependency files.
          never_show = { "node_modules", ".git" },
        },
      },
    },
  },

  -- Outline (Zed: space o outline panel)
  {
    "stevearc/aerial.nvim",
    cmd = "AerialToggle",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>o", "<cmd>AerialToggle!<cr>", desc = "Outline" }, -- Zed: space o
    },
    opts = { layout = { default_direction = "prefer_left" } },
  },

  -- Git hunks in the gutter (Zed: ] c / [ c hunk navigation)
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(l, r, desc)
          vim.keymap.set("n", l, r, { buffer = bufnr, desc = desc })
        end
        map("]c", function() gs.nav_hunk("next") end, "Next hunk")     -- Zed: ] c
        map("[c", function() gs.nav_hunk("prev") end, "Prev hunk")     -- Zed: [ c
      end,
    },
  },

  -- Full git UI via lazygit (Zed: space g git panel)
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>g", "<cmd>LazyGit<cr>", desc = "LazyGit" }, -- Zed: space g
    },
  },

  -- Terminal (Zed: space t / space j bottom dock)
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    keys = {
      { "<leader>t", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal" },        -- Zed: space t
      { "<leader>j", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal (bottom)" }, -- Zed: space j
    },
    opts = {
      size = 15,
      shell = "pwsh -NoLogo",
      open_mapping = [[<c-\>]],
      on_create = function()
        -- Move between the terminal and other splits with Ctrl-hjkl, same as
        -- normal-mode window nav in keymaps.lua — no need to exit terminal mode first.
        local map_opts = { buffer = 0 }
        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], map_opts)
        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], map_opts)
        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], map_opts)
        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], map_opts)

        -- Resize the terminal split without leaving terminal mode. Arrow keys
        -- (not hjkl) so this can't collide with WezTerm/psmux pane bindings.
        vim.keymap.set("t", "<C-Up>", [[<Cmd>resize +2<CR>]], map_opts)
        vim.keymap.set("t", "<C-Down>", [[<Cmd>resize -2<CR>]], map_opts)
        vim.keymap.set("t", "<C-Left>", [[<Cmd>vertical resize -2<CR>]], map_opts)
        vim.keymap.set("t", "<C-Right>", [[<Cmd>vertical resize +2<CR>]], map_opts)
      end,
    },
  },

  -- Comment toggling (Zed: space c c). Native gc also works.
  {
    "numToStr/Comment.nvim",
    keys = {
      { "<leader>cc", function() require("Comment.api").toggle.linewise.current() end, mode = "n", desc = "Toggle comment" }, -- Zed: space c c
      { "<leader>cc", "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>", mode = "v", desc = "Toggle comment" },
    },
    opts = {},
  },

  -- TODO/FIXME/HACK highlighting + Telescope list (space f t) and ]t/[t jump,
  -- same nav convention as gitsigns' ]c/[c hunks above.
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev TODO" },
    },
    opts = {
      -- default patterns require KEYWORD: immediately -- doesn't match this
      -- repo's "TODO(scope): ..." convention (see Agreement.vue). Allow an
      -- optional (scope) between the keyword and the colon.
      highlight = { pattern = [[.*<(KEYWORDS)%(\(.{-}\))?\s*:]] },
      search = { pattern = [[\b(KEYWORDS)(?:\([^)]*\))?:]] },
    },
  },

  -- Autopairs + surround (quality-of-life, close to Zed defaults)
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
    config = function(_, opts)
      local ap = require("nvim-autopairs")
      ap.setup(opts)
      -- Completing a function name auto-inserts () with the cursor inside.
      local ok, cmp = pcall(require, "cmp")
      if ok then
        cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
      end
    end,
  },
  { "kylechui/nvim-surround", event = "VeryLazy", opts = {} },

  -- Auto-close & auto-rename HTML/JSX/Vue tags (treesitter-based).
  -- Typing <div> inserts </div>; editing one tag renames its pair.
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "xml", "javascriptreact", "typescriptreact", "vue", "markdown", "svelte" },
    opts = {},
  },
}
