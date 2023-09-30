local helper = require("pluginbuf.test.helper")
local pluginbuf = helper.require("pluginbuf")

describe("pluginbuf.register()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can custom buffer reading", function()
    pluginbuf.register("pluginbuf-test", {
      {
        path = "/test/",
        read = function(ctx)
          vim.api.nvim_buf_set_lines(ctx.bufnr, 0, -1, false, {
            "line1",
            "line2",
          })
        end,
      },
    })

    vim.cmd.edit("pluginbuf-test:///test")

    assert.exists_pattern([[
^line1
line2$]])
  end)

  it("can custom buffer writing", function()
    local lines
    pluginbuf.register("pluginbuf-test", {
      {
        path = "/test/",
        write = function(ctx)
          lines = vim.api.nvim_buf_get_lines(ctx.bufnr, 0, -1, false)
          ctx:complete()
        end,
      },
    })

    vim.cmd.edit("pluginbuf-test:///test")
    helper.set_lines("line")
    vim.cmd.write()

    assert.is_same({ "line" }, lines)
    assert.is_false(vim.bo.modified)
  end)

  it("can custom buffer sourcing", function()
    local called = false
    pluginbuf.register("pluginbuf-test", {
      {
        path = "/test/",
        source = function(_)
          called = true
        end,
      },
    })

    vim.cmd.edit("pluginbuf-test:///test")
    vim.cmd.source("%")

    assert.is_true(called)
  end)

  it("can use path parameter", function()
    local path_params
    pluginbuf.register("pluginbuf-test", {
      {
        path = "/test/{param1}/{param2}",
        read = function(ctx)
          path_params = ctx.path_params
        end,
      },
    })

    vim.cmd.edit("pluginbuf-test:///test/test1/test2")

    assert.is_same({
      param1 = "test1",
      param2 = "test2",
    }, path_params)
  end)

  it("can use query parameter", function()
    local query_params
    pluginbuf.register("pluginbuf-test", {
      {
        path = "/test",
        query_params = {
          param2 = "test2_default",
          param3 = "test3_default",
        },
        read = function(ctx)
          query_params = ctx.query_params
        end,
      },
    })

    vim.cmd.edit("pluginbuf-test:///test?param1=test1&param2=test2")

    assert.is_same({
      param1 = "test1",
      param2 = "test2",
      param3 = "test3_default",
    }, query_params)
  end)

  it("can use path that is filled with path parameters", function()
    local path
    pluginbuf.register("pluginbuf-test", {
      {
        path = "/test/{param1}/{param2}",
        read = function(ctx)
          path = ctx.path
        end,
      },
    })

    vim.cmd.edit("pluginbuf-test:///test/test1/test2")

    assert.equals("/test/test1/test2", path)
  end)

  it("can use autocmd arguments", function()
    local autocmd_args
    pluginbuf.register("pluginbuf-test", {
      {
        path = "/test/",
        read = function(ctx)
          autocmd_args = ctx.autocmd_args
        end,
      },
    })

    vim.cmd.edit("pluginbuf-test:///test")

    assert.equals(vim.fn.bufnr("%"), autocmd_args.buf)
  end)

  it("can use multiple routes", function()
    local called = false
    pluginbuf.register("pluginbuf-test", {
      {
        path = "/test/1",
        read = function(_)
          error("should not be called")
        end,
      },
      {
        path = "/test/2",
        read = function(_)
          called = true
        end,
      },
    })

    vim.cmd.edit("pluginbuf-test:///test/2")

    assert.is_true(called)
  end)

  it("raises error if there is no matched route", function()
    pluginbuf.register("pluginbuf-test", {
      {
        path = "/test/",
        read = function(_) end,
      },
    })

    local ok, err = pcall(vim.cmd.edit, "pluginbuf-test:///not_found/route")
    assert.is_false(ok)
    assert.matches("not found route", err)
  end)
end)

describe("cmd util", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can use command output for reading", function()
    local on_finished = helper.on_finished()

    pluginbuf.register("pluginbuf-test", {
      {
        path = "/test/",
        read = require("pluginbuf.util").cmd_output({ "echo", "output" }, { callback = on_finished }),
      },
    })

    vim.cmd.edit("pluginbuf-test:///test")
    on_finished.wait()

    assert.exists_pattern([[
^output$]])
  end)

  it("can use buffer content as command input", function()
    local stdout
    local on_finished = helper.on_finished()

    pluginbuf.register("pluginbuf-test", {
      {
        path = "/test/",
        write = require("pluginbuf.util").cmd_input({ "echo", "-n", "-" }, {
          callback = function(o)
            stdout = o.stdout
            on_finished()
          end,
        }),
      },
    })

    vim.cmd.edit("pluginbuf-test:///test")
    helper.set_lines("line")
    vim.cmd.write()
    on_finished.wait()

    assert.equals("line", stdout)
  end)
end)
