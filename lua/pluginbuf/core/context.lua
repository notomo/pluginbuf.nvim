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
function M.new_context(handler_type, bufnr, route, autocmd_args)
  local tbl = {
    path = route.path,
    path_params = route.path_params,
    query_params = route.query_params,
    autocmd_args = autocmd_args,
    bufnr = bufnr,
  }
  return setmetatable(tbl, mapping[handler_type])
end

function WriteContext.complete(self)
  vim.bo[self.bufnr].modified = false
end

return M
