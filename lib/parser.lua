local NULL <const> = json.null

---@generic T
---@alias Parser fun(value: T): T, ValidationError | nil Parses the value

---@description Parser for a built validation chain
---@param builder ChainBuilder
---@diagnostic disable-next-line: lowercase-global
function validationParse(builder)
  validateBuilder(builder)

  local transform = builder.metadata.transform or function(v)
    return v
  end

  ---@type Parser
  return function(value)
    if (type(builder.metadata.nullable) == 'boolean' and builder.metadata.nullable == true) and (value == NULL) then
      return NULL, nil
    end

    if builder.metadata.default ~= nil then
      value = builder.metadata.default
    end

    if not builder.metadata.required and value == nil then
      return transform(value), nil
    end

    if value == nil then
      return nil,
        {
          path = '',
          code = ValidationCodes.Required,
          message = builder.metadata.options.requiredErrorMessage or 'Value is required',
        }
    end

    local correctedType = type(value) --[[@as PrimitiveType]] --

    -- Convert table to object or array
    if (builder.metadata.type == 'object' or builder.metadata.type == 'array') and correctedType == 'table' then
      correctedType = builder.metadata.type
    end

    -- Convert string to enum
    if builder.metadata.type == 'enum' and correctedType == 'string' then
      correctedType = builder.metadata.type
    end

    if builder.metadata.type ~= 'union' and correctedType ~= builder.metadata.type then
      return nil,
        {
          path = '',
          code = ValidationCodes.InvalidType,
          message = builder.metadata.options.invalidTypeMessage
            or ('Invalid type. Received: %s, expected: %s'):format(type(value), builder.metadata.type),
        }
    end

    local isValueAnArray = isArray(value)
    local valueType = type(value)

    -- Additional validation to check wether value is an actual array
    if builder.metadata.type == 'array' then
      if not isValueAnArray then
        return nil,
          {
            path = '',
            code = ValidationCodes.InvalidType,
            message = builder.metadata.options.invalidTypeMessage
              or ('Invalid type. Received: %s, expected: array'):format(valueType == 'table' and 'object' or valueType),
          }
      end
    end

    -- Additional validation to check wether value is an actual object
    if builder.metadata.type == 'object' then
      if isValueAnArray and #value > 0 then
        return nil,
          {
            path = '',
            code = ValidationCodes.InvalidType,
            message = builder.metadata.options.invalidTypeMessage
              or ('Invalid type. Received: %s, expected: object'):format(valueType == 'table' and 'array' or valueType),
          }
      end
    end

    -- String and number parser
    if
      builder.metadata.type == 'string'
      or builder.metadata.type == 'number'
      or builder.metadata.type == 'array' and (builder.metadata.additional and #builder.metadata.additional > 0)
    then
      return alphanumericParser(builder)(value)
    end

    -- Boolean parser
    if builder.metadata.type == 'boolean' then
      return booleanParser(builder)(value)
    end

    -- Enum parser
    if builder.metadata.type == 'enum' then
      return enumParser(builder)(value)
    end

    -- Object parser
    if builder.metadata.type == 'object' then
      return objectParser(builder)(value)
    end

    -- Array parser
    if builder.metadata.type == 'array' then
      return arrayParser(builder)(value)
    end

    -- Union parser
    if builder.metadata.type == 'union' then
      return unionParser(builder)(value)
    end

    error([[
      
      Code: failed_to_parse

      Message:
        Failed to parse the provided value. This is likely due to an issue
        within the parser.

        Please open an issue at `https://github.com/mysbryce/sure_prism/issues/new`
        with the validation chain that caused this error and the error code.
    ]])

    return nil, nil
  end
end
