local M = {}

local ReadContext = {}
ReadContext.__index = ReadContext

local WriteContext = {}
WriteContext.__index = WriteContext

local SourceContext = {}
SourceContext.__index = SourceContext

local mapping = {
  read = ReadContext,
  write = WriteContext,
  source = SourceContext,
}
function M.new_context(handler_type, bufnr, route)
  local tbl = {
    path_params = route.path_params,
    _bufnr = bufnr,
  }
  return setmetatable(tbl, mapping[handler_type])
end

function ReadContext.set_content(self, text)
  local lines = vim.split(text, "\n", { plain = true })
  vim.api.nvim_buf_set_lines(self._bufnr, 0, -1, false, lines)
  vim.bo[self._bufnr].modified = false
end

function WriteContext.content(self)
  local lines = vim.api.nvim_buf_get_lines(self._bufnr, 0, -1, false)
  return table.concat(lines, "\n")
end

function WriteContext.complete(self)
  vim.bo[self._bufnr].modified = false
end

return M
