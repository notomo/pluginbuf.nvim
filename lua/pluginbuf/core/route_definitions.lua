local Route = {}

function Route.new(raw_route, path_params)
  return {
    read = raw_route.read or function() end,
    write = raw_route.write or function() end,
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
    if not definition.is_variable and definition.name == e then
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

function RouteDefinitions.new(scheme_name, raw_route_definitions)
  local prefix_length = #scheme_name + #"://"
  local tbl = {
    _route_definitions = vim
      .iter(raw_route_definitions)
      :map(function(raw_route)
        return RouteDefinition.new(raw_route)
      end)
      :totable(),
    _to_path = function(bufnr)
      local full_path = vim.api.nvim_buf_get_name(bufnr)
      local path = full_path:sub(prefix_length)
      return vim.fn.trim(path, "/", 0)
    end,
  }
  return setmetatable(tbl, RouteDefinitions)
end

function RouteDefinitions.find(self, bufnr, enabled_type)
  local path = self._to_path(bufnr)
  local elements = vim.split(path, "/", { plain = true })
  for _, def in ipairs(self._route_definitions) do
    local route = def:match(elements, enabled_type)
    if route then
      return route, nil
    end
  end
  return nil, "not found route"
end

function RouteDefinitions.has(self, enabled_type)
  for _, def in ipairs(self._route_definitions) do
    if def:has(enabled_type) then
      return true
    end
  end
  return false
end

return RouteDefinitions
