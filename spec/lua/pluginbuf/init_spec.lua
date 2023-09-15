local helper = require("pluginbuf.test.helper")
local pluginbuf = helper.require("pluginbuf")

describe("pluginbuf.register()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("TODO", function()
    pluginbuf.register("pluginbuf", {
      {
        read = function() end,
        write = function() end,
        path = "{test1}/{test2}",
      },
    })
  end)
end)
