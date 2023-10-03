local vim = vim

local M = {}

local trim_trailing_slash = function(path)
  return vim.fn.trim(path, "/", 2)
end

local parse_query = function(raw_query)
  local parts = vim.split(raw_query, "&", { plain = true })
  local params = {}
  vim
    .iter(parts)
    :filter(function(part)
      return part ~= ""
    end)
    :each(function(part)
      local index = part:find("=")
      local k = part:sub(1, index - 1)
      local v = part:sub(index + 1)
      params[k] = v
    end)
  return params
end

function M.to_elements(path)
  local trimmed_path = trim_trailing_slash(path)
  return vim.split(trimmed_path, "/", { plain = true })
end

function M.parse_path_element(path_element)
  local variable_name = path_element:match("{([%w-_]+)}")
  local is_variable = variable_name ~= nil
  if is_variable then
    return variable_name, true
  end
  return path_element, false
end

function M.from_bufnr(bufnr)
  local full_path = vim.api.nvim_buf_get_name(bufnr)
  local scheme_index = full_path:find("://")
  local path = full_path:sub(scheme_index + 3)

  local query_index = path:find("?")
  local query_params = {}
  if query_index then
    local raw_query = path:sub(query_index + 1)
    query_params = parse_query(raw_query)
    path = path:sub(1, query_index - 1)
  end

  local trimmed_path = trim_trailing_slash(path)
  return trimmed_path, query_params
end

return M
