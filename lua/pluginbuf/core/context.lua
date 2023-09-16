local M = {}

local ReadContext = {}
ReadContext.__index = ReadContext

function M.new_read_context(bufnr, route)
  local tbl = {
    path_params = route.path_params,
    _bufnr = bufnr,
  }
  return setmetatable(tbl, ReadContext)
end

function ReadContext.set_content(self, text)
  local lines = vim.split(text, "\n", { plain = true })
  vim.api.nvim_buf_set_lines(self._bufnr, 0, -1, false, lines)
  vim.bo[self._bufnr].modified = false
end

local WriteContext = {}
WriteContext.__index = WriteContext

function M.new_write_context(bufnr, route)
  local tbl = {
    path_params = route.path_params,
    _bufnr = bufnr,
  }
  return setmetatable(tbl, WriteContext)
end

function WriteContext.content(self)
  local lines = vim.api.nvim_buf_get_lines(self._bufnr, 0, -1, false)
  return table.concat(lines, "\n")
end

function WriteContext.complete(self)
  vim.bo[self._bufnr].modified = false
end

local SourceContext = {}
SourceContext.__index = SourceContext

function M.new_source_context(bufnr, route)
  local tbl = {
    path_params = route.path_params,
    _bufnr = bufnr,
  }
  return setmetatable(tbl, SourceContext)
end

return M
