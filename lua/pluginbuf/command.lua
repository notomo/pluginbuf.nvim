local M = {}

local register_one = function(handler_type, route_definitions, event, group, pattern)
  if not route_definitions:has(handler_type) then
    return
  end

  vim.api.nvim_create_autocmd({ event }, {
    group = group,
    pattern = pattern,
    callback = function(autocmd_args)
      local bufnr = tonumber(autocmd_args.buf)

      local route, err = route_definitions:find(bufnr, handler_type)
      if err then
        error("[pluginbuf] " .. err)
      end

      local ctx = require("pluginbuf.core.context").new_context(handler_type, bufnr, route, autocmd_args)

      local handler = route[handler_type]
      handler(ctx)
    end,
  })
end

function M.register(scheme_name, raw_route_definitions)
  local group = vim.api.nvim_create_augroup("pluginbuf_" .. scheme_name, {})
  local pattern = scheme_name .. "://{*,*/*}"

  local route_definitions = require("pluginbuf.core.route_definitions").new(raw_route_definitions)

  register_one("read", route_definitions, "BufReadCmd", group, pattern)
  register_one("write", route_definitions, "BufWriteCmd", group, pattern)
  register_one("source", route_definitions, "SourceCmd", group, pattern)
end

return M
