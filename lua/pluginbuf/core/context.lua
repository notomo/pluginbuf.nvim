local M = {}

local ReadContext = {}
ReadContext.__index = ReadContext

function M.new_read_context(bufnr)
  local tbl = {
    _bufnr = bufnr,
  }
  return setmetatable(tbl, ReadContext)
end

function ReadContext.set_content(self, text)
  vim.api.nvim_buf_set_lines(self._bufnr, 0, -1, false, vim.split(text, "\n", { plain = true }))
  vim.bo[self._bufnr].modified = false
end

local WriteContext = {}
WriteContext.__index = WriteContext

function M.new_write_context(bufnr)
  local tbl = {
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

return M
