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
          ctx:set_content([[
line1
line2]])
        end,
      },
    })

    vim.cmd.edit("pluginbuf-test://test")

    assert.exists_pattern([[
^line1
line2$]])
  end)

  it("can custom buffer writing", function()
    local content
    pluginbuf.register("pluginbuf-test", {
      {
        path = "/test/",
        write = function(ctx)
          content = ctx:content()
          ctx:complete()
        end,
      },
    })

    vim.cmd.edit("pluginbuf-test://test")
    helper.set_lines("line")
    vim.cmd.write()

    assert.is_same("line", content)
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

    vim.cmd.edit("pluginbuf-test://test")
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

    vim.cmd.edit("pluginbuf-test://test/test1/test2")

    assert.is_same({
      param1 = "test1",
      param2 = "test2",
    }, path_params)
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

    vim.cmd.edit("pluginbuf-test://test")

    assert.equals(vim.fn.bufnr("%"), autocmd_args.buf)
  end)
end)
