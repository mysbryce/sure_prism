---@param options CustomOptions | nil
function prism:string(options)
  ---@class StringChainBuilder: ChainBuilder
  local builder = {}

  builder.metadata = {}
  builder.metadata.type = 'string'
  builder.metadata.required = true
  builder.metadata.additional = {}
  builder.metadata.passUndefined = false
  builder.metadata.options = options or {}

  builder.parse = validationParse(builder)
  builder.min = PrimitiveMethods.min(builder)
  builder.max = PrimitiveMethods.max(builder)
  builder.startsWith = PrimitiveMethods.startsWith(builder)
  builder.endsWith = PrimitiveMethods.endsWith(builder)
  builder.email = PrimitiveMethods.email(builder)
  builder.identifier = PrimitiveMethods.identifier(builder)
  builder.default = PrimitiveMethods.default(builder)
  builder.nullable = PrimitiveMethods.nullable(builder)
  builder.optional = PrimitiveMethods.optional(builder)
  builder.transform = PrimitiveMethods.transform(builder)

  return builder
end

---@param options CustomOptions | nil
function prism:number(options)
  ---@class NumberChainBuilder: ChainBuilder
  local builder = {}

  builder.metadata = {}
  builder.metadata.type = 'number'
  builder.metadata.required = true
  builder.metadata.additional = {}
  builder.metadata.passUndefined = false
  builder.metadata.options = options or {}

  builder.parse = validationParse(builder)
  builder.min = PrimitiveMethods.min(builder)
  builder.max = PrimitiveMethods.max(builder)
  builder.default = PrimitiveMethods.default(builder)
  builder.nullable = PrimitiveMethods.nullable(builder)
  builder.optional = PrimitiveMethods.optional(builder)
  builder.transform = PrimitiveMethods.transform(builder)

  return builder
end

---@param enums string[]
---@param options CustomOptions | nil
function prism:enum(enums, options)
  if type(enums) ~= 'table' or not isArray(enums) or #enums <= 0 then
    error('Options must be a non-empty array')
  end

  ---@class EnumChainBuilder: ChainBuilder
  local builder = {}

  builder.metadata = {}
  builder.metadata.type = 'enum'
  builder.metadata.enums = enums
  builder.metadata.required = true
  builder.metadata.passUndefined = false
  builder.metadata.options = options or {}

  builder.parse = validationParse(builder)
  builder.default = PrimitiveMethods.default(builder)
  builder.nullable = PrimitiveMethods.nullable(builder)
  builder.optional = PrimitiveMethods.optional(builder)
  builder.transform = PrimitiveMethods.transform(builder)

  return builder
end

---@param options CustomOptions | nil
function prism:boolean(options)
  ---@class BooleanChainBuilder: ChainBuilder
  local builder = {}

  builder.metadata = {}
  builder.metadata.required = true
  builder.metadata.type = 'boolean'
  builder.metadata.passUndefined = false
  builder.metadata.options = options or {}

  builder.parse = validationParse(builder)
  builder.default = PrimitiveMethods.default(builder)
  builder.nullable = PrimitiveMethods.nullable(builder)
  builder.optional = PrimitiveMethods.optional(builder)
  builder.transform = PrimitiveMethods.transform(builder)

  return builder
end

---@param fields table<string, ChainBuilder>
---@param options CustomOptions | nil
function prism:object(fields, options)
  if type(fields) ~= 'table' or (isArray(fields) and #fields > 0) then
    error('Fields must be a table')
  end

  ---@class ObjectChainBuilder: ChainBuilder
  local builder = {}

  builder.metadata = {}
  builder.metadata.type = 'object'
  builder.metadata.required = true
  builder.metadata.fields = fields
  builder.metadata.passUndefined = false
  builder.metadata.options = options or {}

  builder.parse = validationParse(builder)
  builder.nullable = PrimitiveMethods.nullable(builder)
  builder.default = PrimitiveMethods.default(builder)
  builder.optional = PrimitiveMethods.optional(builder)
  builder.transform = PrimitiveMethods.transform(builder)

  ---@deprecated Please use catchall, it can be removed at any time
  builder.passthrough = TableMethods.passthrough(builder)
  builder.catchall = TableMethods.passthrough(builder)

  return builder
end

---@param objectBuilder ObjectChainBuilder
---@param fields table<string, ChainBuilder>
---@param options CustomOptions | nil
function prism:extends(objectBuilder, fields, options)
  if type(objectBuilder) ~= 'table' then
    error('Object builder must be a table')
  end

  if type(fields) ~= 'table' then
    error('Fields must be a table')
  end

  objectBuilder.metadata.fields = mergeTable(objectBuilder.metadata.fields, fields)
  objectBuilder.metadata.options = options or {}

  return objectBuilder
end

---@param element ChainBuilder
---@param options CustomOptions | nil
function prism:array(element, options)
  if type(element) ~= 'table' then
    error('Element must be a ChainBuilder')
  end

  -- Don't allow unions in arrays
  if element.metadata.type == 'union' then
    error('Unions are not allowed in arrays')
  end

  ---@class ArrayChainBuilder: ChainBuilder
  local builder = {}

  builder.metadata = {}
  builder.metadata.type = 'array'
  builder.metadata.additional = {}
  builder.metadata.required = true
  builder.metadata.element = element
  builder.metadata.passUndefined = false
  builder.metadata.options = options or {}

  builder.parse = validationParse(builder)
  builder.min = PrimitiveMethods.min(builder)
  builder.max = PrimitiveMethods.max(builder)
  builder.default = PrimitiveMethods.default(builder)
  builder.nullable = PrimitiveMethods.nullable(builder)
  builder.optional = PrimitiveMethods.optional(builder)
  builder.transform = PrimitiveMethods.transform(builder)

  return builder
end

---@param builders ChainBuilder[]
---@param options CustomOptions | nil
function prism:union(builders, options)
  if type(builders) ~= 'table' or not isArray(builders) then
    error('Builders must be an array')
  end

  ---@class UnionChainBuilder: ChainBuilder
  local builder = {}

  builder.metadata = {}
  builder.metadata.type = 'union'
  builder.metadata.required = true
  builder.metadata.passUndefined = false
  builder.metadata.options = options or {}
  builder.metadata.unionBuilders = builders

  builder.parse = validationParse(builder)
  builder.optional = PrimitiveMethods.optional(builder)

  return builder
end
