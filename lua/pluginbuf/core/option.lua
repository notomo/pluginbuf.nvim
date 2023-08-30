local M = {}

local default_register_opts = {
  read = nil,
  write = nil,
}

function M.new_register_opts(raw_opts)
  vim.validate({ raw_opts = { raw_opts, "table", true } })
  raw_opts = raw_opts or {}
  return vim.tbl_deep_extend("force", default_register_opts, raw_opts)
end

return M
