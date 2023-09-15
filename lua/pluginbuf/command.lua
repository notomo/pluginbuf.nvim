local M = {}

function M.register(scheme_name, raw_route_definitions)
  local group = vim.api.nvim_create_augroup("pluginbuf_" .. scheme_name, {})
  local pattern = scheme_name .. "://{*,*/*}"

  local route_definitions = require("pluginbuf.core.route_definitions").new(scheme_name, raw_route_definitions)

  if route_definitions:has("read") then
    vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
      group = group,
      pattern = pattern,
      callback = function(args)
        local bufnr = tonumber(args.buf)

        local route, err = route_definitions:find(bufnr, "read")
        if err then
          error(err)
        end

        local ctx = require("pluginbuf.core.context").new_read_context(bufnr, route)
        route.read(ctx)
      end,
    })
  end

  if route_definitions:has("write") then
    vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
      group = group,
      pattern = pattern,
      callback = function(args)
        local bufnr = tonumber(args.buf)

        local route, err = route_definitions:find(bufnr, "write")
        if err then
          error(err)
        end

        local ctx = require("pluginbuf.core.context").new_write_context(bufnr, route)
        route.write(ctx)
      end,
    })
  end
end

return M
