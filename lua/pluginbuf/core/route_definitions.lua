local Route = {}

function Route.new(raw_route_definition, path, path_params, query_params)
  return {
    read = raw_route_definition.read,
    write = raw_route_definition.write,
    source = raw_route_definition.source,
    path = path,
    path_params = path_params,
    query_params = vim.tbl_deep_extend("force", raw_route_definition.query_params or {}, query_params),
  }
end

local RouteDefinition = {}
RouteDefinition.__index = RouteDefinition

function RouteDefinition.new(raw_route_definition)
  local tbl = {
    _path_definitions = require("pluginbuf.core.path_definitions").new(raw_route_definition.path),
    _raw_route_definition = raw_route_definition,
  }
  return setmetatable(tbl, RouteDefinition)
end

function RouteDefinition.match(self, handler_type, path, query_params)
  if not self:has(handler_type) then
    return nil
  end

  local path_elements = require("pluginbuf.core.path").to_elements(path)
  if #path_elements ~= #self._path_definitions then
    return nil
  end

  local path_params = {}
  for i, path_element in ipairs(path_elements) do
    local definition = self._path_definitions[i]
    if not definition.is_variable and definition.name ~= path_element then
      return nil
    end
    if definition.is_variable then
      path_params[definition.name] = path_element
    end
  end

  return Route.new(self._raw_route_definition, path, path_params, query_params)
end

function RouteDefinition.has(self, handler_type)
  return self._raw_route_definition[handler_type] ~= nil
end

local RouteDefinitions = {}
RouteDefinitions.__index = RouteDefinitions

function RouteDefinitions.new(raw_route_definitions)
  local tbl = {
    _route_definitions = vim
      .iter(raw_route_definitions)
      :map(function(raw_route_definition)
        return RouteDefinition.new(raw_route_definition)
      end)
      :totable(),
  }
  return setmetatable(tbl, RouteDefinitions)
end

function RouteDefinitions.find(self, bufnr, handler_type)
  local path, query_params = require("pluginbuf.core.path").from_bufnr(bufnr)

  for _, definition in ipairs(self._route_definitions) do
    local route = definition:match(handler_type, path, query_params)
    if route then
      return route, nil
    end
  end

  return nil, "not found route for: " .. path
end

function RouteDefinitions.has(self, handler_type)
  return vim.iter(self._route_definitions):any(function(definition)
    return definition:has(handler_type)
  end)
end

return RouteDefinitions
