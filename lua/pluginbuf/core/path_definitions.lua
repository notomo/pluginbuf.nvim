local M = {}

local new_element = function(name, is_variable, match)
  return {
    name = name,
    is_variable = is_variable,
    match = match,
  }
end

local new_variable_element = function(name, raw_pattern)
  local pattern = raw_pattern or [=[\v^[^/]+$]=]
  local regex = vim.regex(pattern)
  return new_element(name, true, function(path_element)
    return regex:match_str(path_element)
  end)
end

local new_fixed_element = function(name)
  return new_element(name, false, function(path_element)
    return name == path_element
  end)
end

function M.new(path, raw_path_params)
  local path_params = raw_path_params or {}
  local path_elements = require("pluginbuf.core.path").to_elements(path)
  return vim
    .iter(path_elements)
    :map(function(path_element)
      local variable_name = path_element:match("{([%w-_]+)}")
      if variable_name then
        local raw_pattern = path_params[variable_name]
        return new_variable_element(variable_name, raw_pattern)
      end
      return new_fixed_element(path_element)
    end)
    :totable()
end

return M
