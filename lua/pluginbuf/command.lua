local M = {}

function M.register(scheme_name, raw_opts)
  local opts = require("pluginbuf.core.option").new_register_opts(raw_opts)

  local group = vim.api.nvim_create_augroup("pluginbuf_" .. scheme_name, {})
  local pattern = scheme_name .. "://{*,*/*}"

  if opts.read then
    vim.api.nvim_create_autocmd({ "BufReadCmd" }, {
      group = group,
      pattern = pattern,
      callback = function(args)
        local bufnr = tonumber(args.buf)
        local ctx = require("pluginbuf.core.context").new_read_context(bufnr)
        opts.read(ctx)
      end,
    })
  end

  if opts.write then
    vim.api.nvim_create_autocmd({ "BufWriteCmd" }, {
      group = group,
      pattern = pattern,
      callback = function(args)
        local bufnr = tonumber(args.buf)
        local ctx = require("pluginbuf.core.context").new_write_context(bufnr)
        return opts.write(ctx)
      end,
    })
  end
end

return M
