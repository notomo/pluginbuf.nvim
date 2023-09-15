local M = {}

--- @class PluginbufRouteDefinition
--- @field path string TODO
--- @field read fun(ctx)? TODO
--- @field write fun(ctx)? TODO

--- Registers scheme handler.
--- @param scheme_name string TODO
--- @param route_definitions PluginbufRouteDefinition[] |PluginbufRouteDefinition|
function M.register(scheme_name, route_definitions)
  require("pluginbuf.command").register(scheme_name, route_definitions)
end

return M
