PrimitiveMethods = {}

---@param builder ChainBuilder
function PrimitiveMethods.min(builder)
  ---@description Enforces a minimum value for a string or number
  ---@param minimum number The minimum value
  ---@param errorMessage ErrorMessage The error message to be returned when the validation fails
  return function(minimum, errorMessage)
    if type(minimum) ~= 'number' then
      error('Minimum value must be a number')
    end

    builder.metadata.additional = builder.metadata.additional or {}

    ---@type Validation
    local validation = {
      validate = function(value)
        local length = 0

        if builder.metadata.type == 'string' then
          length = string.len(value)
        end

        if builder.metadata.type == 'number' then
          length = value
        end

        if builder.metadata.type == 'array' then
          length = #value
        end

        if length < minimum then
          return {
            path = '',
            code = ValidationCodes.TooSmall,
            message = errorMessage or ('Invalid minimum length. Received %s, expected: %s'):format(length, minimum),
          }
        end

        return true
      end,
    }

    table.insert(builder.metadata.additional, validation)

    return builder
  end
end

---@param builder ChainBuilder
function PrimitiveMethods.max(builder)
  ---@param maximum number
  ---@param errorMessage string?
  return function(maximum, errorMessage)
    if type(maximum) ~= 'number' then
      error('Maximum value must be a number')
    end

    builder.metadata.additional = builder.metadata.additional or {}

    ---@type Validation
    local validation = {
      validate = function(value)
        local length = 0

        if builder.metadata.type == 'string' then
          length = string.len(value)
        end

        if builder.metadata.type == 'number' then
          length = value
        end

        if builder.metadata.type == 'array' then
          length = #value
        end

        if length > maximum then
          return {
            path = '',
            code = ValidationCodes.TooBig,
            message = errorMessage or ('Invalid maximum length. Received %s, expected: %s'):format(length, maximum),
          }
        end

        return true
      end,
    }

    table.insert(builder.metadata.additional, validation)

    return builder
  end
end

---@param builder ChainBuilder
function PrimitiveMethods.optional(builder)
  return function()
    builder.metadata.required = false

    return builder
  end
end

---@param builder ChainBuilder
function PrimitiveMethods.startsWith(builder)
  ---@param textToSearch string
  ---@param errorMessage string?
  return function(textToSearch, errorMessage)
    if type(textToSearch) ~= 'string' then
      error('textToSearch must be a string')
    end

    builder.metadata.additional = builder.metadata.additional or {}

    ---@type Validation
    local validation = {
      validate = function(value)
        if not value:sub(1, #textToSearch) == textToSearch then
          return {
            path = '',
            code = ValidationCodes.MissingStartsWith,
            message = errorMessage or ('Could not find target text. Searched %s, Input: %s'):format(textToSearch, value),
          }
        end

        return true
      end,
    }

    table.insert(builder.metadata.additional, validation)

    return builder
  end
end

---@param builder ChainBuilder
function PrimitiveMethods.endsWith(builder)
  ---@param textToSearch string
  ---@param errorMessage string?
  return function(textToSearch, errorMessage)
    if type(textToSearch) ~= 'string' then
      error('textToSearch must be a string')
    end

    builder.metadata.additional = builder.metadata.additional or {}

    ---@type Validation
    local validation = {
      validate = function(value)
        if not value:sub(1, #textToSearch) == textToSearch then
          return {
            path = '',
            code = ValidationCodes.MissingEndsWith,
            message = errorMessage or ('Could not find target text. Searched %s, Input: %s'):format(textToSearch, value),
          }
        end

        return true
      end,
    }

    table.insert(builder.metadata.additional, validation)

    return builder
  end
end

---@param builder ChainBuilder
function PrimitiveMethods.email(builder)
  ---@param errorMessage string?
  return function(errorMessage)
    builder.metadata.additional = builder.metadata.additional or {}

    ---@type Validation
    local validation = {
      validate = function(value)
        local pattern = '^[%w%.%_%-]+@[%w%.%_%-]+%.[%w%.%_%-]+$'
        if value:match(pattern) == nil then
          return {
            path = '',
            code = ValidationCodes.InvalidEmail,
            message = errorMessage or ('Target string could not match email pattern. Input: %s'):format(value),
          }
        end

        return true
      end,
    }

    table.insert(builder.metadata.additional, validation)

    return builder
  end
end

---@param builder ChainBuilder
function PrimitiveMethods.identifier(builder)
  ---@alias IdentifierType
  ---| 'steam'
  ---| 'discord'
  ---| 'license'
  ---| 'license2'
  ---| 'fivem'
  ---| 'xbl'
  ---@param target IdentifierType | IdentifierType[] | nil
  ---@param errorMessage string?
  return function(target, errorMessage)
    builder.metadata.additional = builder.metadata.additional or {}

    ---@type Validation
    local validation = {
      validate = function(value)
        if type(value) ~= 'string' or not value:find(':') then
          return {
            path = '',
            code = ValidationCodes.InvalidIdentifier,
            message = errorMessage or ('Not a valid identifier pattern, Must starts with [IDENTIFIER-TYPE]:[VALUE]. Input: %s'):format(value),
          }
        end

        if target == nil then
          return true
        end

        local targets = type(target) == 'table' and target or { target }
        local prefix = value:match('([^:]+):')
        local found = false
        for _, t in ipairs(targets) do
          if prefix == t then
            found = true
            break
          end
        end

        if not found then
          return {
            path = '',
            code = ValidationCodes.InvalidIdentifier,
            message = errorMessage or ('Not found target identifier. Expected: %s, Input: %s'):format(target, value),
          }
        end

        return true
      end,
    }

    table.insert(builder.metadata.additional, validation)

    return builder
  end
end
