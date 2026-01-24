---@param t1 table
---@param t2 table
---@diagnostic disable-next-line: lowercase-global
function mergeTable(t1, t2)
  for k, v2 in pairs(t2) do
    local v1 = t1[k]
    local type1 = type(v1)
    local type2 = type(v2)

    if type1 == 'table' and type2 == 'table' then
      mergeTable(v1, v2)
    else
      t1[k] = v2
    end
  end

  return t1
end
