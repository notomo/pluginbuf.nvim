local M = {}

local PathDefinition = {}

function PathDefinition.new(name, is_variable)
  return {
    name = name,
    is_variable = is_variable,
  }
end

function M.new(path)
  local normalized = vim.fn.trim(path, "/", 0)
  local elements = vim.split(normalized, "/", { plain = true })
  return vim
    .iter(elements)
    :map(function(e)
      local matched = e:match("{([%w-_]+)}")
      local is_variable = matched ~= nil
      if not is_variable then
        return PathDefinition.new(e, is_variable)
      end
      return PathDefinition.new(matched, is_variable)
    end)
    :totable()
end

return M
