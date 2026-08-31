-- LSP: mirrors your Zed setup (vtsls for TS/JS, Vue, ESLint) plus json/css/html/lua.
-- Uses Neovim 0.11+ native vim.lsp.config/enable API (the old lspconfig framework
-- is deprecated on 0.12 and doesn't ship the vue_ls config).
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "b0o/SchemaStore.nvim", -- JSON/YAML schema catalog (GitLab CI, GitHub Actions, docker-compose, ...)
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- LSP keymaps attach per-buffer (Zed: g d/D/y/i/r, space r n, space c a/c d, space d n/p)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
          end
          -- Multi-result jumps go through Telescope (picker + file preview) instead
          -- of the raw quickfix split. Single results still jump directly.
          map("gd", "<cmd>Telescope lsp_definitions<cr>", "Go to definition")            -- Zed: g d
          map("gD", vim.lsp.buf.declaration, "Go to declaration")                        -- Zed: g shift-d
          map("gy", "<cmd>Telescope lsp_type_definitions<cr>", "Go to type definition")  -- Zed: g y
          map("gi", "<cmd>Telescope lsp_implementations<cr>", "Go to implementation")    -- Zed: g i
          map("gr", "<cmd>Telescope lsp_references<cr>", "Find all references")          -- Zed: g r
          map("<leader>rn", vim.lsp.buf.rename, "Rename")                  -- Zed: space r n
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")        -- Zed: space c a
          map("<leader>cd", vim.lsp.buf.hover, "Hover docs")               -- Zed: space c d
          map("<leader>cs", vim.lsp.buf.signature_help, "Signature help")  -- parameter hints on demand
          -- Also pop signature help automatically in insert mode with Ctrl-s.
          vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "Signature help" })
          map("<leader>dn", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next diagnostic")  -- Zed: space d n
          map("<leader>dp", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev diagnostic") -- Zed: space d p
          map("<leader>de", vim.diagnostic.open_float, "Show full error under cursor")
          -- Jump to the next/prev ERROR only (skip warnings/hints)
          map("<leader>dN", function() vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true }) end, "Next error only")
          map("<leader>dP", function() vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true }) end, "Prev error only")

          -- Document highlight: rest the cursor on a symbol and every other use /
          -- definition of it in this file lights up (LspReferenceText/Read/Write).
          -- Fires on CursorHold (updatetime = 250ms) and clears the moment you move.
          -- Skipped for .vue buffers: @vue/typescript-plugin's linkedCodeFeatureWorker
          -- hits a "Debug Failure. False expression." assertion inside TS's own
          -- getDocumentHighlights on this TS version — an upstream vue-language-tools/
          -- vtsls bug, not something fixable from this config.
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and vim.bo[ev.buf].filetype ~= "vue" and client:supports_method("textDocument/documentHighlight") then
            local hl = vim.api.nvim_create_augroup("lsp_doc_highlight_" .. ev.buf, { clear = true })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = hl, buffer = ev.buf, callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = hl, buffer = ev.buf, callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = "rounded" },
        -- Gutter glyphs per severity (0.10+ signs API). Falls back gracefully if a
        -- Nerd Font isn't active — swap these for E/W/H/I if the glyphs show as boxes.
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN]  = "",
            [vim.diagnostic.severity.INFO]  = "",
            [vim.diagnostic.severity.HINT]  = "󰌶",
          },
        },
      })

      -- Vue "hybrid mode": vtsls handles TS, vue_ls handles the template.
      local vue_plugin = {
        name = "@vue/typescript-plugin",
        location = vim.fn.stdpath("data")
          .. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
        languages = { "vue" },
        -- Without this, vtsls loads the plugin but never wires up its completion
        -- path: hover/go-to-def still work (different code path), but
        -- textDocument/completion returns 0 items for every .vue <script> block.
        configNamespace = "typescript",
      }

      -- Shared defaults applied to every server.
      vim.lsp.config("*", { capabilities = capabilities })

      vim.lsp.config("vtsls", {
        settings = {
          vtsls = {
            tsserver = { globalPlugins = { vue_plugin } },
            -- Was true to force the project's own node_modules/typescript (avoids a
            -- "Debug Failure. False expression." crash on plain .ts files), but that
            -- pairs workspace TS 5.8.3 with the @vue/typescript-plugin bundled inside
            -- mason's vue-language-server, which ships its own TS 6.0.3 — the version
            -- skew throws "<semantic> TypeScript Server Error" on every .vue file and
            -- tsserver falls back to raw-parsing <template> as TS. Let vtsls use its
            -- bundled TS (matched to the plugin) instead.
            autoUseWorkspaceTsdk = false,
          },
          typescript = { updateImportsOnFileMove = { enabled = "always" } },
          javascript = { updateImportsOnFileMove = { enabled = "always" } },
        },
        filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
      })

      -- Lint on save instead of on every keystroke -- full-project ESLint runs
      -- (this repo's flat config pulls in typescript-eslint + vue rules) were
      -- adding per-keystroke overhead while typing.
      vim.lsp.config("eslint", {
        settings = { run = "onSave" },
      })

      vim.lsp.config("lua_ls", {
        settings = { Lua = { diagnostics = { globals = { "vim" } } } },
      })

      -- Emmet: abbreviation expansion (e.g. `div.container>ul>li*3` → full markup).
      -- vscode-html-language-server does NOT ship Emmet, so this fills that gap.
      vim.lsp.config("emmet_language_server", {
        filetypes = { "html", "css", "scss", "sass", "less", "javascriptreact", "typescriptreact", "vue" },
      })

      -- YAML: schema-aware validation/completion for GitLab CI (.gitlab-ci.yml),
      -- GitHub Actions (.github/workflows/*), docker-compose, etc. via SchemaStore.
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" }, -- use SchemaStore.nvim instead of the built-in store
            schemas = require("schemastore").yaml.schemas(),
            validate = true,
            format = { enable = true },
            keyOrdering = false, -- don't force alphabetical keys (GitLab CI stages are ordered by intent)
          },
        },
      })

      -- docker-compose LSP attaches to the `yaml.docker-compose` filetype; make sure
      -- compose files get that filetype so both yamlls and the compose server run.
      vim.filetype.add({
        pattern = {
          ["docker%-compose%.ya?ml"] = "yaml.docker-compose",
          ["compose%.ya?ml"] = "yaml.docker-compose",
          [".*docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
        },
      })

      local servers = {
        "vtsls", "vue_ls", "eslint", "tailwindcss", "jsonls", "cssls", "html", "lua_ls",
        "yamlls", "dockerls", "docker_compose_language_service", "emmet_language_server",
      }

      require("mason-lspconfig").setup({
        ensure_installed = servers,
        automatic_enable = false, -- we enable explicitly below
      })

      vim.lsp.enable(servers)
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "roobert/tailwindcss-colorizer-cmp.nvim", -- color swatch in the popup for Tailwind classes
    },
    config = function()
      local cmp = require("cmp")
      require("tailwindcss-colorizer-cmp").setup({ color_square_width = 2 })
      cmp.setup({
        snippet = {
          expand = function(args) require("luasnip").lsp_expand(args.body) end,
        },
        -- Bordered popups; the documentation window shows the item's docs/type
        -- as you Tab through suggestions (like Zed's completion detail panel).
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),   -- scroll doc window down
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),  -- scroll doc window up
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          -- Smart Tab: cycle the cmp popup when it's open, otherwise a plain tab.
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        -- Show the item kind + which source it came from in the menu.
        formatting = {
          fields = { "abbr", "kind", "menu" },
          format = function(entry, item)
            item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snip]",
              buffer = "[Buf]",
              path = "[Path]",
            })[entry.source.name]
            -- Prepend a color swatch to Tailwind color-class suggestions.
            return require("tailwindcss-colorizer-cmp").formatter(entry, item)
          end,
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },
}
