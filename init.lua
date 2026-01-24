--- Only allow Lua 5.4
if not _VERSION:find('5.4') then
  error('^1Lua 5.4 must be enabled in the resource manifest!^0', 2)
end

local surePrism = 'sure_prism'
local resourceName = GetCurrentResourceName()

--- Avoid initializing the module if it's within itself
if resourceName == surePrism then
  return
end

if GetResourceState(surePrism) ~= 'started' then
  error('^1sure_prism must be started before this resource.^0', 0)
end

local LoadResourceFile = LoadResourceFile

--- Must be manually updated
local moduleRoutes = {
  'lib/generator.lua',

  --- [validator:utils]
  'lib/validator/utils/table.lua',
  'lib/validator/utils/is-array.lua',
  'lib/validator/utils/validate-builder.lua',
  --- [validator:root]
  'lib/validator/enums.lua',
  --- [validator:parsers]
  'lib/validator/parsers/alphanumeric-parser.lua',
  'lib/validator/parsers/boolean-parser.lua',
  'lib/validator/parsers/array-parser.lua',
  'lib/validator/parsers/enum-parser.lua',
  'lib/validator/parsers/object-parser.lua',
  'lib/validator/parsers/union-parser.lua',
  'lib/validator/parser.lua',
  --- [validator:methods]
  'lib/validator/methods/primitive-methods.lua',
  'lib/validator/methods/table-methods.lua',
  --- [validator:root]
  'lib/validator/primitive-builders.lua',

  --- [event:root]
  'lib/event/use.lua',
}

---@param module string
local function loadModule(module)
  local chunk = LoadResourceFile(surePrism, module)

  if not chunk then
    return
  end

  local fun, err = load(chunk, ('@@sure_prism/%s'):format(module))

  if not fun or err then
    return error(('\n^1Error importing module (%s): %s^0'):format(module, err), 3)
  end

  fun()
end

for i = 1, #moduleRoutes do
  local name = moduleRoutes[i]

  loadModule(name)
end
