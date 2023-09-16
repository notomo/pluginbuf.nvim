local M = {}

local normalize = function(path)
  return vim.fn.trim(path, "/", 0)
end

function M.to_elements(path)
  local normalized_path = normalize(path)
  return vim.split(normalized_path, "/", { plain = true })
end

function M.from_bufnr(bufnr)
  local full_path = vim.api.nvim_buf_get_name(bufnr)
  local index = full_path:find("://")
  local path = full_path:sub(index + 1)
  return normalize(path)
end

return M
