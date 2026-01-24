<img src="https://i.ibb.co/JWYjSnpw/Untitled-2025-11-18-1706-1.webp" />

# Prism - Data validation builder

`sure_prism` (Validation Builder) is a tool that is focused on building validation schemas to ensure that the data received matches a specific specification.
[Documentation](https://prism.e2ends.xyz/)

## Fork Purpose

Purpose This fork is maintained for use across my upcoming development resources. While it retains the core logic of the original Lua data validation library, I am actively extending it to include:
  - Custom Validation Rules: Tailored specifically for my project requirements.
  - Enhanced Performance: Optimizations for high-frequency resource calls.
  - Bug Fixes & Compatibility: Ensuring seamless integration with modern Lua environments.

## Setup

This resource exposes an initialization file, to use it, simply add the following to your `fxmanifest.lua` file:

```lua
shared_scripts {
  '@sure_prism/init.lua',
}
```

## Supported data types

- Arrays: `prism:array(ChainBuilder, CustomOptions | nil)`
- Objects: `prism:object(table<string, ChainBuilder>, CustomOptions | nil)`
- Extends: `prism:extends(ObjectChainBuilder, table<string, ChainBuilder>, CustomOptions | nil)`
- Strings: `prism:string(CustomOptions | nil)`
- Numbers: `prism:number(CustomOptions | nil)`
- Booleans: `prism:boolean(CustomOptions | nil)`
- Enums: `prism:enum(string[], CustomOptions | nil)`
- Unions: `prism:union(ChainBuilder[], CustomOptions | nil)`

## Naming

- `ChainBuilder` - The builder that is generated from a initial data type builder `prism:string()` will generate a specific `StringChainBuilder`
- `CustomOptions` - Custom options for invalid error messages `(table)`
  - `invalidTypeMessage` - Message displayed when a values type doesn't match
  - `requiredErrorMessage` - Message displayed when a value is `nil` but required
- `ValidationError` - A table that is composed of values that indicate what error occurred
  - `path` - The path to the field that failed
  - `message` - The error message
  - `code` An enum code for that specific error

## Additional validation methods

- `startsWith(textToSearch, errorMessage?)`
  - `textToSearch` Define text to search in the begin of text
  - Allowed on data types:
    - String
- `endsWith(textToSearch, errorMessage?)`
  - `textToSearch` Define text to search in the end of text
  - Allowed on data types:
    - String
- `email(errorMessage?)` Validate that text is correct an email pattern
  - Allowed on data types:
    - String
- `identifier(target: IdentifierType | IdentifierType[] | nil, errorMessage?)` Validate that text is correct an identifier pattern
  - `IdentifierType` contains
    - `steam`
    - `discord`
    - `license`
    - `license2`
    - `fivem`
    - `xbl`
  - Allowed on data types:
    - String
- `min(number, errorMessage?)`
  - `number` Indicates the lowest amount of the value for it to be valid:
    - Number - Size
    - String - Length of string
    - Array - Length of elements
- `max(number, errorMessage?)`
  - `number` - Indicates the highest amount of the value for it to be valid:
    - Number - Size
    - String - Length of string
    - Array - Length of elements
- `passthrough()` - Allows unspecified values in the schema to be passed through
  - By default this is set to `false`
  - Allowed on data types:
    1. `object`
- `optional()` - Allows the value to be `nil`
  - By default this is set to false
  - Allowed on all data types
- `parse(value): value | nil, ValidationError | nil` - Parses the provided value and either returns it or the validation error that occured

## Usage

### Basic value object validation

```lua
local playerValidation <const> = prism:object({
  ssn = prism:string()
})

local validPlayer <const> = { ssn = "123456789" }
local invalidPlayer <const> = { ssn = nil } -- Or {}

local validParsed <const>, validError <const> = playerValidation.parse(validPlayer)
local invalidParsed <const>, invalidError <const> = playerValidation.parse(invalidPlayer)

-- ✅ Passes the validation
print(json.encode(validParsed)) -- { ssn = "123456789 }
print(json.encode(validError)) -- nil

-- ❌ Fails the validation
print(json.encode(invalidParsed)) -- nil
print(json.encode(invalidError)) -- { code = "required", message = "Value is required", }
```

### Enum validation

```lua
local playerJobEnum <const> = prism:enum({ "Police", "Firefighter", "Doctor" })

local validJob <const> = playerJobEnum.parse("Police")
print(validJob) -- "Police

local _, invalidJobError <const> = playerJobEnum.parse("Teacher")
print(json.encode(invalidJobError)) -- { code = "invalid_enum", message = "Value is not a valid enum", path = "" }

-- It is case sensitive, meaning that "police, POLICE, pOlIcE, ...etc" will fail the validation
```

### Union validation

#### Caveats

1. Cannot be used within an array: `prism:array(prism:union(...))`. This is due to the fact that the array builder expects a single type and not a union of types.

```lua
local playerJobNameOrIdUnion <const> = prism:union({
  prism:string(),
  prism:number(),
})

local validString <const> = playerJobNameOrIdUnion.parse("Police")
print(validString) -- "Police"

local validNumber <const> = playerJobNameOrIdUnion.parse(123)
print(validNumber) -- 123

local _, invalidError <const> = playerJobNameOrIdUnion.parse({})
print(json.encode(invalidError)) -- { code = "invalid_union", message = "Invalid union. Received: table, expected: string, number", path = "" }
```

### Methods `.min, .max, .optional`

```lua
local playerNameValidation <const> = prism:string().min(1).max(10)

-- ✅ Passes the validation since it is more than 1 characted and less than 10
local valid = playerNameValidation.parse("John")
-- ❌ Fails the validation since it is more than 10
local _, longError = playerNameValidation.parse("John The Mighty")
-- ❌ Fails the validation since it is less than 1
local _, shortError = playerNameValidation.parse("")
-- ❌ Fails the validation since it is nil
local _, nilError = playerNameValidation.parse(nil)

-- If you wish to allow nil values, you can simply append the `.optional()` method
-- Or do if from the start of the validation builder
-- ✅ Passes the validation since nil is allowed
local validNil <const> = playerNameValidation.optional().parse(nil)
-- Or
local playerNilNameValidation <const> = prism:string().min(1).max(10).optional()
local validNewNil <const> = playerNilNameValidation.parse(nil)
```

### Method `.passthrough`

```lua
local playerValidation <const> = prism:object({
  name = prism:string().min(1).max(10),
})

-- Will remove the `job` field since it is not present in the schema
local nonPassthroughParsed <const> = playerValidation.parse({
  name = "John",
  job = "Police",
})
print(json.encode(nonPassthroughParsed)) -- { name = "John" }

-- Will keep the `job` field since `.passthrough()` is appended.
local passthroughParsed <const> = playerValidation.passthrough().parse({
  name = "John",
  job = "Police",
})
print(json.encode(passthroughParsed)) -- { name = "John", job = "Police" }
```

### Custom error options

```lua
local playerValidation <const> = prism:object({
  name = prism:string({
    requiredErrorMessage = "Name is required",
    invalidTypeMessage = "Name must be a string",
  }),
})

local _, typeError <const> = playerValidation.parse({ name = 123 })
print(json.encode(typeError)) -- { code = "invalid_type", message = "Name must be a string", path = "" }

local _, requiredError <const> = playerValidation.parse({})
print(json.encode(requiredError)) -- { code = "required", message = "Name is required", path = ""}
```

## Contribution

Issues are encouraged, this was only a small module that I created to safely mutate data in the database without breaking changes and if more custom functionality is needed, please create an issue for it. I will occasionally update this module with more features and improvements.
