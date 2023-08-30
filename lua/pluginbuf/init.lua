local M = {}

--- @class PluginbufRegisterOption
--- @field read fun()? TODO
--- @field write fun()? TODO

--- Registers scheme handler.
--- @param scheme_name string TODO
--- @param opts PluginbufRegisterOption? |PluginbufRegisterOption|
function M.register(scheme_name, opts)
  require("pluginbuf.command").register(scheme_name, opts)
end

return M
