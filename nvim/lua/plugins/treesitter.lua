-- Syntax highlighting + treesitter-based indentation.
--
-- Uses nvim-treesitter's `main` branch (required for Neovim 0.12+). The old
-- `master` branch is frozen and does NOT support 0.12 -- its highlighter crashed
-- with "method 'range' (a nil value)" while scrolling. On `main`, highlighting is
-- provided by Neovim's own runtime: we call vim.treesitter.start() per buffer via
-- a FileType autocmd. Parsers live in stdpath('data')/site/parser.
--
-- Parser compilation toolchain (this machine has no MSVC/gcc, only zig):
--   * tree-sitter CLI installed via `scoop install tree-sitter`.
--   * A cc/c++ shim in stdpath('data')/ts-compiler that forwards to `zig cc`
--     and rewrites the msvc target triple to gnu, so zig builds self-contained
--     parser DLLs with its bundled mingw-w64. `zig` must stay on PATH.
-- setup_compiler_env() below points tree-sitter at that shim so :TSInstall /
-- :TSUpdate work. If the shim is ever removed, parser install/update will fail
-- but existing compiled parsers keep working.

local langs = {
  "lua", "vim", "vimdoc", "bash",
  "javascript", "typescript", "tsx", "vue",
  "json", "jsonc", "html", "css", "scss", "yaml",
  "markdown", "markdown_inline", "dockerfile",
}

local function setup_compiler_env()
  if vim.fn.has("win32") ~= 1 then
    return
  end
  local ccdir = vim.fn.stdpath("data") .. "/ts-compiler"
  if vim.fn.filereadable(ccdir .. "/cc.exe") ~= 1 then
    return
  end
  ccdir = ccdir:gsub("/", "\\")
  if not (";" .. (vim.env.PATH or "") .. ";"):find(";" .. vim.pesc(ccdir) .. ";", 1, false) then
    vim.env.PATH = ccdir .. ";" .. (vim.env.PATH or "")
  end
  vim.env.CC = "cc"
  vim.env.CXX = "c++"
end

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  -- Recompile installed parsers whenever the plugin updates, so parsers stay in
  -- sync with the branch's query files (a mismatch is what crashed the old setup).
  build = function()
    setup_compiler_env()
    pcall(function()
      require("nvim-treesitter").update():wait(600000)
    end)
  end,
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    setup_compiler_env()

    -- Install any configured parser that isn't present yet (async, no blocking).
    local nts = require("nvim-treesitter")
    local have = {}
    for _, l in ipairs(nts.get_installed("parsers") or {}) do
      have[l] = true
    end
    local missing = vim.tbl_filter(function(l)
      return not have[l]
    end, langs)
    if #missing > 0 then
      pcall(function()
        nts.install(missing)
      end)
    end

    -- Start treesitter highlighting + indentation for a buffer, but only when a
    -- parser for its filetype is available (pcall keeps it error-free otherwise).
    local function ts_attach(buf)
      local ft = vim.bo[buf].filetype
      if ft == "" then
        return
      end
      local lang = vim.treesitter.language.get_lang(ft) or ft
      if not pcall(vim.treesitter.language.add, lang) then
        return
      end
      pcall(vim.treesitter.start, buf, lang)
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
      callback = function(ev)
        ts_attach(ev.buf)
      end,
    })

    -- The plugin loads on BufReadPost, so the first file's FileType event fired
    -- before this autocmd existed -- attach to already-open buffers now.
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) then
        ts_attach(buf)
      end
    end
  end,
}
