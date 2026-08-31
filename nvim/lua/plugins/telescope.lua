-- Telescope covers all your Zed finder/palette bindings.
return {
  "nvim-telescope/telescope.nvim",
  -- master (not 0.1.x): the old 0.1.x previewer calls nvim-treesitter's removed
  -- master-branch API (ft_to_lang / configs), which crashes with treesitter on
  -- its `main` branch. master's previewer uses Neovim's runtime treesitter API.
  branch = "master",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- Native fzf sorter for speed. Built with `make` if present, else with
    -- `zig cc` (this machine has zig but no make/gcc/cmake). Disabled only if
    -- neither is available, in which case telescope falls back to its Lua sorter.
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      cond = vim.fn.executable("make") == 1 or vim.fn.executable("zig") == 1,
      build = function(plugin)
        if vim.fn.executable("make") == 1 then
          vim.fn.system({ "make" }) -- lazy runs build with cwd = plugin.dir
          return
        end
        -- Zig ships a full C compiler (`zig cc`); compile the shared lib directly.
        local target = vim.fn.has("win32") == 1 and "libfzf.dll" or "libfzf.so"
        vim.fn.mkdir(plugin.dir .. "/build", "p")
        vim.fn.system({
          "zig", "cc", "-O3", "-Wall", "-fpic", "-shared",
          "-o", plugin.dir .. "/build/" .. target,
          plugin.dir .. "/src/fzf.c",
        })
      end,
    },
  },
  keys = {
    { "<leader><space>", "<cmd>Telescope commands<cr>", desc = "Command palette" },      -- Zed: space space
    { "<leader><tab>", "<cmd>Telescope buffers<cr>", desc = "Switch buffer" },           -- Zed: space tab (tab switcher)
    { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },              -- Zed: space f f
    { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Grep (search)" },            -- Zed: space f g
    { "<leader>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Project symbols" }, -- Zed: space f s
    { "<leader>fp", "<cmd>Telescope oldfiles<cr>", desc = "Recent files/projects" },     -- Zed: space f p
    { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },                -- search :help docs
    { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },                    -- discover your own bindings
    { "<leader>dl", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics list" },       -- Zed: space d l
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        -- Include hidden/dotfiles in grep too; exclude .git internals and
        -- node_modules explicitly. These projects aren't git repos, so ripgrep
        -- has no .gitignore to trust — without the node_modules glob it would
        -- grep through ~70k dependency files (slow + noisy).
        vimgrep_arguments = {
          "rg", "--color=never", "--no-heading", "--with-filename",
          "--line-number", "--column", "--smart-case",
          "--hidden", "--glob", "!**/.git/*", "--glob", "!**/node_modules/*",
        },
      },
      pickers = {
        find_files = {
          -- Show dotfiles (.env, .prettierrc, .gitignore…) but skip .git
          -- internals and node_modules. node_modules is excluded explicitly
          -- (not via .gitignore) because these dirs aren't git repos — see the
          -- vimgrep_arguments note above.
          find_command = {
            "rg", "--files", "--hidden",
            "--glob", "!**/.git/*", "--glob", "!**/node_modules/*",
          },
        },
      },
    })
    pcall(telescope.load_extension, "fzf")
  end,
}
