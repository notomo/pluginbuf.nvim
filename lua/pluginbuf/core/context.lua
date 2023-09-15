local M = {}

local ReadContext = {}
ReadContext.__index = ReadContext

function M.new_read_context(scheme_name, bufnr, path_parameter_definitions)
  local path = vim.api.nvim_buf_get_name(bufnr)
  local tbl = {
    _bufnr = bufnr,
    path_params = M._parse_path_params(scheme_name, path, path_parameter_definitions),
  }
  return setmetatable(tbl, ReadContext)
end

function ReadContext.set_content(self, text)
  vim.api.nvim_buf_set_lines(self._bufnr, 0, -1, false, vim.split(text, "\n", { plain = true }))
  vim.bo[self._bufnr].modified = false
end

local WriteContext = {}
WriteContext.__index = WriteContext

function M.new_write_context(scheme_name, bufnr, path_parameter_definitions)
  local path = vim.api.nvim_buf_get_name(bufnr)
  local tbl = {
    _bufnr = bufnr,
    path_params = M._parse_path_params(scheme_name, path, path_parameter_definitions),
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

function M._parse_path_params(scheme_name, full_path, path_parameter_definitions)
  local path = full_path:gsub("^" .. vim.pesc(scheme_name) .. "://", "")
  local normalized = vim.fn.trim(path, "/", 0)
  local elements = vim.split(normalized, "/", { plain = true })

  local path_params = {}
  vim.iter(elements):enumerate():each(function(i, e)
    local definition = path_parameter_definitions[i]
    if not definition then
      return
    end
    if not definition.is_variable then
      return
    end
    path_params[definition.name] = e
  end)
  return path_params
end

return M
