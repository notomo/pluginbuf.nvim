local M = {}

local new_element = function(name, is_variable)
  return {
    name = name,
    is_variable = is_variable,
  }
end

local new_variable_element = function(name)
  return new_element(name, true)
end

local new_fixed_element = function(name)
  return new_element(name, false)
end

function M.new(path)
  local path_elements = require("pluginbuf.core.path").to_elements(path)
  return vim
    .iter(path_elements)
    :map(function(path_element)
      local variable_name = path_element:match("{([%w-_]+)}")
      if variable_name then
        return new_variable_element(variable_name)
      end
      return new_fixed_element(path_element)
    end)
    :totable()
end

return M
