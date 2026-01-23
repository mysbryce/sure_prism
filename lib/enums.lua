---@enum ValidationCode
ValidationCodes = {
  Custom = 'custom',
  TooBig = 'too_big',
  Required = 'required',
  TooSmall = 'too_small',
  InvalidType = 'invalid_type',
  InvalidEnum = 'invalid_enum',
  InvalidUnion = 'invalid_union',
  InvalidEmail = 'invalid_email',
  MissingStartsWith = 'missing_starts_with',
  MissingEndsWith = 'missing_ends_with',
  InvalidIdentifier = 'invalid_identifier',
}

---@enum AllowedPrimitiveBuilderType
AllowedPrimitiveBuilderTypes = {
  enum = 'enum',
  array = 'array',
  union = 'union',
  string = 'string',
  number = 'number',
  object = 'object',
  boolean = 'boolean',
}
