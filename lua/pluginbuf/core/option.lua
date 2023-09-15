local M = {}

local default_register_opts = {
  read = nil,
  write = nil,
  path = "",
}

function M.new_register_opts(raw_opts)
  vim.validate({ raw_opts = { raw_opts, "table", true } })
  raw_opts = raw_opts or {}
  local opts = vim.tbl_deep_extend("force", default_register_opts, raw_opts)
  opts.path_parameter_definitions = M._parse_path_paramerter_definitions(opts.path)
  return opts
end

function M._parse_path_paramerter_definitions(path)
  local normalized = vim.fn.trim(path, "/", 0)
  local elements = vim.split(normalized, "/", { plain = true })
  return vim
    .iter(elements)
    :map(function(e)
      local matched = e:match("{([%w-_]+)}")
      if not matched then
        return {
          name = e,
          is_variable = false,
        }
      end
      return {
        name = matched,
        is_variable = true,
      }
    end)
    :totable()
end

return M
