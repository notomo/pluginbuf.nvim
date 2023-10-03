local vim = vim

local PathDefinitions = {}
PathDefinitions.__index = PathDefinitions

function PathDefinitions.new(raw_path_definition)
  local tbl = {
    _param_indicies = raw_path_definition.params or {},
    _pattern = raw_path_definition.pattern or "\\v.+",
  }
  return setmetatable(tbl, PathDefinitions)
end

function PathDefinitions.match(self, path)
  local all_matches = vim.fn.matchlist(path, self._pattern)
  if #all_matches == 0 then
    return nil
  end
  local matches = vim.list_slice(all_matches, 2)

  local params = {}
  for key, index in pairs(self._param_indicies) do
    params[key] = matches[index]
  end
  return params
end

return PathDefinitions
