local PLUGINS = {}

-- Root class for the validation builder

---@alias ErrorMessage string | nil
---@alias PrimitiveType "string" | "number" | "object" | "array" | "boolean" | "enum" | "union" | "extends"
---@alias ValidationMethod fun(value: any): boolean | ValidationError The function to validate the value, if string is returned, the validation failed

---@class CustomOptions The custom options for the validation
---@field invalidTypeMessage ErrorMessage The message to be returned when the validation fails
---@field requiredErrorMessage ErrorMessage The message to be returned when the field is required and not present

---@generic T Transform data
---@class PrimitiveMetadata The metadata for the primitive validation
---@field type PrimitiveType The type of the validation
---@field required boolean Whether the field is required or not
---@field options CustomOptions | nil The custom options for the validation
---@field fields table<string, ChainBuilder> | nil The fields of the object
---@field passUndefined boolean Whether to passthrough fields that have not been defined
---@field additional Validation[] | nil The additional validations to be used
---@field element ChainBuilder | nil The element of the array
---@field enums string[] | nil The enums for the validation
---@field unionBuilders ChainBuilder[] | nil The builders for the union
---@field startsWith string | nil Check that target string exists at start of text
---@field endsWith string | nil Check that target string exists at end of text
---@field default unknown Default value if it's nil or undefined
---@field nullable boolean | nil Make it can be null if it's json
---@field transform fun(data: T): T

---@class Validation
---@field validate ValidationMethod

---@class ValidationError
---@field path string The field path that failed the validation
---@field message string The message of the validation error
---@field code ValidationCode The code of the validation error

---@class ChainBuilder
---@field metadata PrimitiveMetadata The metadata for the primitive validation
---@field parse Parser Parses the value

---@class PrimitiveBuilder
---@field metadata PrimitiveMetadata The metadata for the primitive validation
prism = {}

---@param plugin { name: string, init: fun()?, [string]: any }
function prism:use(plugin)
  if type(plugin) ~= 'table' then
    error('Plugin must be a table')
  end

  if plugin.name == nil then
    error('Missing name of plugin')
  end

  if PLUGINS[plugin.name] then
    return
  end

  PLUGINS[plugin.name] = plugin

  if type(plugin.init) == 'function' then
    local ok, err = xpcall(plugin.init, debug.traceback)
    if not ok then
      PLUGINS[plugin.name] = nil
      error(('Plugin %s error during initialization: %s'):format(plugin.name, err))
    end
  end
end

-- Register an export for other resources to be able to use the Prism
exports('getPrism', function()
  return prism
end)

-- Make it supports ox_lib
lib = lib or {}
lib.prism = prism
