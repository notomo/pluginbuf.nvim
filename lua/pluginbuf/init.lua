local M = {}

--- @class PluginbufContext
--- @field path string path that is filled with path parameters
--- @field path_params table<string,string> resolved path parameters
--- @field query_params table<string,any> resolved query parameters
--- @field autocmd_args table<string,any>: |nvim_create_autocmd()| callback arguments.

--- @class PluginbufRouteDefinition
--- @field path string path part in `scheme_name://path?query`. This can include parameter by `{parameter_name}`.
--- @field path_params table<string,string>? path parameter to vim regex pattern mapping.
--- @field query_params table<string,any>? default query parameters
--- @field read fun(ctx:PluginbufContext)?  be invoked if buffer matches with path. related: |BufReadCmd|
--- @field write fun(ctx:PluginbufContext)? be invoked if buffer matches with path. related: |BufWriteCmd|
--- @field source fun(ctx:PluginbufContext)? be invoked if buffer matches with path. related: |SourceCmd|

--- Registers scheme handler.
--- @param scheme_name string scheme name part in `scheme_name://path?query`
--- @param route_definitions PluginbufRouteDefinition[] |PluginbufRouteDefinition|
function M.register(scheme_name, route_definitions)
  require("pluginbuf.command").register(scheme_name, route_definitions)
end

--- Unregisters scheme handler.
--- @param scheme_name string scheme name part in `scheme_name://path?query`
function M.unregister(scheme_name)
  require("pluginbuf.command").unregister(scheme_name)
end

return M
