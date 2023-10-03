local M = {}

function M.cmd_output(cmd, opts)
  opts = opts or {}
  opts.callback = opts.callback or function(_) end
  opts.text = true
  return function(ctx)
    vim.system(
      cmd,
      opts,
      vim.schedule_wrap(function(o)
        if o.code ~= 0 then
          vim.notify("[pluginbuf] " .. o.stderr, vim.log.levels.ERROR)
          opts.callback(o)
          return
        end

        local lines = vim.split(o.stdout, "\n", { plain = true })
        vim.api.nvim_buf_set_lines(ctx.bufnr, 0, -1, false, lines)
        vim.bo[ctx.bufnr].modified = false
        opts.callback(o)
      end)
    )
  end
end

function M.cmd_input(cmd, opts)
  opts = opts or {}
  opts.callback = opts.callback or function(_) end
  opts.text = true
  return function(ctx)
    local lines = vim.api.nvim_buf_get_lines(ctx.bufnr, 0, -1, false)
    local content = table.concat(lines, "\n")
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
          vim.notify("[pluginbuf] " .. o.stderr, vim.log.levels.ERROR)
          opts.callback(o)
          return
        end

        vim.bo[ctx.bufnr].modified = false
        opts.callback(o)
      end)
    )
  end
end

function M.path(path)
  local capture_index = 1
  local params = {}
  local path_patterns = vim
    .iter(require("pluginbuf.core.path").to_elements(path))
    :map(function(path_element)
      local name, is_variable = require("pluginbuf.core.path").parse_path_element(path_element)
      if not is_variable then
        return name
      end

      params[name] = capture_index
      capture_index = capture_index + 1

      return "([^/]+)"
    end)
    :totable()

  local pattern = [[\v^]] .. table.concat(path_patterns, "/") .. "$"

  return {
    pattern = pattern,
    params = params,
  }
end

return M
