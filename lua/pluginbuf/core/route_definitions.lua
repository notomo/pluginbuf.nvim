local Route = {}

function Route.new(raw_route, path_params)
  return {
    read = raw_route.read,
    write = raw_route.write,
    path_params = path_params,
  }
end

local RouteDefinition = {}
RouteDefinition.__index = RouteDefinition

function RouteDefinition.new(raw_route)
  local tbl = {
    _path_definitions = require("pluginbuf.core.path_definitions").new(raw_route.path),
    _enabled_types = {
      read = raw_route.read ~= nil,
      write = raw_route.write ~= nil,
    },
    _raw_route = raw_route,
  }
  return setmetatable(tbl, RouteDefinition)
end

function RouteDefinition.match(self, path_elements, enabled_type)
  if not self._enabled_types[enabled_type] then
    return nil
  end

  if #path_elements ~= #self._path_definitions then
    return nil
  end

  local path_params = {}
  for i, e in ipairs(path_elements) do
    local definition = self._path_definitions[i]
    if not definition.is_variable and definition.name ~= e then
      return nil
    end
    if definition.is_variable then
      path_params[definition.name] = e
    end
  end

  return Route.new(self._raw_route, path_params)
end

function RouteDefinition.has(self, enabled_type)
  return self._enabled_types[enabled_type]
end

local RouteDefinitions = {}
RouteDefinitions.__index = RouteDefinitions

function RouteDefinitions.new(raw_route_definitions)
  local tbl = {
    _route_definitions = vim
      .iter(raw_route_definitions)
      :map(function(raw_route)
        return RouteDefinition.new(raw_route)
      end)
      :totable(),
  }
  return setmetatable(tbl, RouteDefinitions)
end

function RouteDefinitions.find(self, bufnr, enabled_type)
  local path = require("pluginbuf.core.path").from_bufnr(bufnr)
  local path_elements = require("pluginbuf.core.path").to_elements(path)
  for _, definition in ipairs(self._route_definitions) do
    local route = definition:match(path_elements, enabled_type)
    if route then
      return route, nil
    end
  end
  return nil, "not found route for: " .. path
end

function RouteDefinitions.has(self, enabled_type)
  return vim.iter(self._route_definitions):any(function(definition)
    return definition:has(enabled_type)
  end)
end

return RouteDefinitions
