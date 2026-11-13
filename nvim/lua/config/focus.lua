-- Function-focus mode: dim everything except the function/block the cursor
-- is currently inside, using Neovim's built-in vim.treesitter API (not the
-- old nvim-treesitter Lua modules -- those don't exist on the `main` branch,
-- see treesitter.lua). Toggle with <leader>z.

local M = {}

local ns = vim.api.nvim_create_namespace("focus_dim")
local group = vim.api.nvim_create_augroup("user_focus_dim", { clear = true })
local enabled = false

-- Node types that count as a "function scope" across the languages in
-- treesitter.lua (js/ts/tsx/vue embed js, lua has two function node kinds).
local scope_types = {
  function_declaration = true,
  function_definition = true,
  function_expression = true,
  arrow_function = true,
  method_definition = true,
  generator_function = true,
  generator_function_declaration = true,
}

-- vim.treesitter.get_node() stays on the root language's own tree; it does
-- not descend into injected trees (e.g. Vue SFCs, where <script> content is
-- a separate `javascript`/`typescript` LanguageTree, not a sub-node of the
-- vue tree's raw_text node). Resolve the injected tree for the cursor's
-- range ourselves and search that.
local function find_scope_node()
  local ok, parser = pcall(vim.treesitter.get_parser)
  if not ok or not parser then
    return nil
  end

  -- language_for_range only sees injections that have already been parsed.
  -- That parse isn't guaranteed to have happened yet (e.g. right after a
  -- buffer loads, or before the highlighter's next redraw), so force it.
  parser:parse(true)

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1
  local range = { row, col, row, col }

  local lang_ok, lang_tree = pcall(parser.language_for_range, parser, range)
  if not lang_ok or not lang_tree then
    return nil
  end

  local tree = lang_tree:trees()[1]
  local root = tree and tree:root()
  if not root then
    return nil
  end

  local node = root:named_descendant_for_range(row, col, row, col)
  while node do
    if scope_types[node:type()] then
      return node
    end
    node = node:parent()
  end
  return nil
end

local function clear(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

local function dim(bufnr, srow, scol, erow, ecol)
  vim.api.nvim_buf_set_extmark(bufnr, ns, srow, scol, {
    end_row = erow,
    end_col = ecol,
    hl_group = "Comment",
    hl_eol = true,
    priority = 200,
    strict = false,
  })
end

local function refresh()
  local bufnr = vim.api.nvim_get_current_buf()
  clear(bufnr)
  if not enabled then
    return
  end

  local total = vim.api.nvim_buf_line_count(bufnr)

  local node = find_scope_node()
  if not node then
    -- Not inside any function: nothing to focus on, so dim the whole buffer
    -- rather than leaving it normal -- color = "focused", so no focus = no color.
    dim(bufnr, 0, 0, total, 0)
    return
  end

  local srow, scol, erow, ecol = node:range()

  if srow > 0 then
    dim(bufnr, 0, 0, srow, 0)
  end
  if scol > 0 then
    dim(bufnr, srow, 0, srow, scol)
  end
  local last_line = vim.api.nvim_buf_get_lines(bufnr, erow, erow + 1, false)[1] or ""
  if ecol < #last_line then
    dim(bufnr, erow, ecol, erow, #last_line)
  end
  if erow + 1 < total then
    dim(bufnr, erow + 1, 0, total, 0)
  end
end

function M.enable()
  enabled = true
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufEnter", "WinScrolled" }, {
    group = group,
    callback = refresh,
  })
  refresh()
end

function M.disable()
  enabled = false
  vim.api.nvim_clear_autocmds({ group = group })
  clear(vim.api.nvim_get_current_buf())
end

function M.toggle()
  if enabled then
    M.disable()
  else
    M.enable()
  end
end

return M
