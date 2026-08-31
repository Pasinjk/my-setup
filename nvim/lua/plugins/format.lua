-- Formatting (Zed: space f r -> Format; prettier + eslint fixAll per language).
-- Zed had format_on_save: off, so this is manual-trigger only, matching your workflow.
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>fr",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" },
        desc = "Format",
      },
    },
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        markdown = { "prettier" },
        yaml = { "prettier" },
        lua = { "stylua" },
      },
      -- Prefer the project's local prettier when present.
      default_format_opts = { lsp_format = "fallback" },
    },
  },

  -- Auto-install the formatters above through Mason, the same way LSP servers are
  -- installed via mason-lspconfig. Without this, prettier/stylua have to be on PATH
  -- (or in the project's node_modules) or conform silently formats nothing.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    opts = {
      ensure_installed = { "prettier", "stylua" },
      run_on_start = true,
    },
  },
}
