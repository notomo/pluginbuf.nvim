local M = {}

function M.cmd_output(cmd, opts)
  opts = opts or {}
  opts.text = true
  return function(ctx)
    vim.system(
      cmd,
      opts,
      vim.schedule_wrap(function(o)
        if o.code ~= 0 then
          vim.notify("[pluginbuf]: " .. o.stderr, vim.log.levels.ERROR)
          return
        end
        ctx:set_content(o.stdout)
      end)
    )
  end
end

function M.cmd_input(cmd, opts)
  opts = opts or {}
  opts.text = true
  return function(ctx)
    local content = ctx:content()
    if type(cmd) == "table" and vim.tbl_contains(cmd, "-") then
      cmd = vim
        .iter(cmd)
        :map(function(e)
          if e == "-" then
            -- TODO: modify option?
            return vim.trim(content)
          end
          return e
        end)
        :totable()
    else
      opts.stdin = content
    end

    vim.system(
      cmd,
      opts,
      vim.schedule_wrap(function(o)
        if o.code ~= 0 then
          vim.notify("[pluginbuf]: " .. o.stderr, vim.log.levels.ERROR)
          return
        end
        ctx:complete()
      end)
    )
  end
end

return M
