-- =============================================================================
-- sure_prism Test Suite
-- =============================================================================
-- Runs in standalone Lua 5.4 by stubbing FiveM-specific APIs.
-- Usage: lua54 tests/test_prism.lua
-- =============================================================================

-- ─── Stubs for FiveM APIs ─────────────────────────────────────────────────────

json = json or {}
json.null = setmetatable({}, { __tostring = function() return 'null' end })
json.encode = json.encode or function(v)
  if type(v) == 'table' then
    local parts = {}
    for k, val in pairs(v) do
      parts[#parts + 1] = tostring(k) .. '=' .. tostring(val)
    end
    return '{' .. table.concat(parts, ', ') .. '}'
  end
  return tostring(v)
end

function GetCurrentResourceName() return 'test_resource' end
function GetResourceState() return 'started' end
function LoadResourceFile() return '' end
function AddEventHandler() end
function RegisterNetEvent() end
function exports() end

lib = lib or {}

-- ─── Minimal Test Framework ───────────────────────────────────────────────────

---@class TestRunner
local T = {
  passed = 0,
  failed = 0,
  errors = {},
  current_suite = '',
}

---@param suite_name string
---@param fn fun()
function T.describe(suite_name, fn)
  T.current_suite = suite_name
  print(('\n── %s ──'):format(suite_name))
  fn()
end

---@param test_name string
---@param fn fun()
function T.it(test_name, fn)
  local ok, err = pcall(fn)
  if ok then
    T.passed = T.passed + 1
    print(('  ✓ %s'):format(test_name))
  else
    T.failed = T.failed + 1
    table.insert(T.errors, ('[%s] %s: %s'):format(T.current_suite, test_name, err))
    print(('  ✗ %s'):format(test_name))
    print(('    → %s'):format(err))
  end
end

---@param a any
---@param b any
---@param msg string?
function T.eq(a, b, msg)
  if a ~= b then
    error(msg or ('expected %s, got %s'):format(tostring(b), tostring(a)), 2)
  end
end

---@param v any
---@param msg string?
function T.truthy(v, msg)
  if not v then error(msg or 'expected truthy value', 2) end
end

---@param v any
---@param msg string?
function T.falsy(v, msg)
  if v then error(msg or 'expected falsy value, got: ' .. tostring(v), 2) end
end

---@param fn fun()
---@param msg string?
function T.throws(fn, msg)
  local ok = pcall(fn)
  if ok then error(msg or 'expected function to throw', 2) end
end

function T.summary()
  print(('\n══════════════════════════════════════════'))
  print(('  Results: %d passed, %d failed'):format(T.passed, T.failed))
  print(('══════════════════════════════════════════'))
  if #T.errors > 0 then
    print('\nFailed tests:')
    for _, e in ipairs(T.errors) do
      print('  • ' .. e)
    end
  end
  print('')
  return T.failed == 0
end

-- ─── Load Modules (simulating FiveM shared_scripts order) ─────────────────────

dofile('lib/validator/utils/table.lua')
dofile('lib/validator/utils/is-array.lua')
dofile('lib/validator/utils/validate-builder.lua')

dofile('lib/validator/enums.lua')
dofile('lib/generator.lua')

dofile('lib/validator/parsers/alphanumeric-parser.lua')
dofile('lib/validator/parsers/boolean-parser.lua')
dofile('lib/validator/parsers/array-parser.lua')
dofile('lib/validator/parsers/enum-parser.lua')
dofile('lib/validator/parsers/object-parser.lua')
dofile('lib/validator/parsers/union-parser.lua')
dofile('lib/validator/parser.lua')

dofile('lib/validator/methods/primitive-methods.lua')
dofile('lib/validator/methods/table-methods.lua')

dofile('lib/validator/primitive-builders.lua')

print('═══════════════════════════════════════════')
print('  sure_prism Test Suite')
print('═══════════════════════════════════════════')

-- =============================================================================
-- STRING BUILDER
-- =============================================================================

T.describe('prism:string()', function()
  T.it('parses a valid string', function()
    local s = prism:string()
    local val, err = s.parse('hello')
    T.eq(val, 'hello')
    T.falsy(err)
  end)

  T.it('rejects non-string values', function()
    local s = prism:string()
    local val, err = s.parse(42)
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'invalid_type')
  end)

  T.it('rejects nil when required', function()
    local s = prism:string()
    local val, err = s.parse(nil)
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'required')
  end)

  T.it('accepts nil when optional', function()
    local s = prism:string()
    s.optional()
    local val, err = s.parse(nil)
    T.falsy(err)
    -- val is nil (optional with no default)
  end)

  T.it('applies default only when value is nil', function()
    local s = prism:string()
    s.default('fallback')
    local val, err = s.parse(nil)
    T.eq(val, 'fallback')
    T.falsy(err)
  end)

  T.it('does NOT overwrite provided value with default', function()
    local s = prism:string()
    s.default('fallback')
    local val, err = s.parse('actual')
    T.eq(val, 'actual')
    T.falsy(err)
  end)

  T.it('enforces min length', function()
    local s = prism:string()
    s.min(5)
    local val, err = s.parse('hi')
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'too_small')
  end)

  T.it('passes min length check', function()
    local s = prism:string()
    s.min(2)
    local val, err = s.parse('hello')
    T.eq(val, 'hello')
    T.falsy(err)
  end)

  T.it('enforces max length', function()
    local s = prism:string()
    s.max(3)
    local val, err = s.parse('hello')
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'too_big')
  end)

  T.it('passes max length check', function()
    local s = prism:string()
    s.max(10)
    local val, err = s.parse('hello')
    T.eq(val, 'hello')
    T.falsy(err)
  end)

  T.it('validates startsWith correctly', function()
    local s = prism:string()
    s.startsWith('hello')
    local val, err = s.parse('hello world')
    T.eq(val, 'hello world')
    T.falsy(err)
  end)

  T.it('rejects startsWith mismatch', function()
    local s = prism:string()
    s.startsWith('world')
    local val, err = s.parse('hello world')
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'missing_starts_with')
  end)

  T.it('validates endsWith correctly', function()
    local s = prism:string()
    s.endsWith('world')
    local val, err = s.parse('hello world')
    T.eq(val, 'hello world')
    T.falsy(err)
  end)

  T.it('rejects endsWith mismatch', function()
    local s = prism:string()
    s.endsWith('hello')
    local val, err = s.parse('hello world')
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'missing_ends_with')
  end)

  T.it('validates email pattern', function()
    local s = prism:string()
    s.email()
    local val, err = s.parse('user@example.com')
    T.eq(val, 'user@example.com')
    T.falsy(err)
  end)

  T.it('rejects invalid email', function()
    local s = prism:string()
    s.email()
    local val, err = s.parse('not-an-email')
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'invalid_email')
  end)

  T.it('validates identifier with prefix', function()
    local s = prism:string()
    s.identifier('steam')
    local val, err = s.parse('steam:123456')
    T.eq(val, 'steam:123456')
    T.falsy(err)
  end)

  T.it('rejects identifier with wrong prefix', function()
    local s = prism:string()
    s.identifier('steam')
    local val, err = s.parse('discord:123456')
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'invalid_identifier')
  end)

  T.it('validates identifier with array of prefixes', function()
    local s = prism:string()
    s.identifier({ 'steam', 'discord' })
    local val, err = s.parse('discord:123456')
    T.eq(val, 'discord:123456')
    T.falsy(err)
  end)

  T.it('rejects non-identifier string', function()
    local s = prism:string()
    s.identifier()
    local val, err = s.parse('nocolonhere')
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'invalid_identifier')
  end)

  T.it('applies transform function', function()
    local s = prism:string()
    s.transform(function(v) return v:upper() end)
    local val, err = s.parse('hello')
    T.eq(val, 'HELLO')
    T.falsy(err)
  end)

  T.it('supports nullable with json.null', function()
    local s = prism:string()
    s.nullable()
    local val, err = s.parse(json.null)
    T.eq(val, json.null)
    T.falsy(err)
  end)
end)

-- =============================================================================
-- NUMBER BUILDER
-- =============================================================================

T.describe('prism:number()', function()
  T.it('parses a valid number', function()
    local n = prism:number()
    local val, err = n.parse(42)
    T.eq(val, 42)
    T.falsy(err)
  end)

  T.it('rejects non-number values', function()
    local n = prism:number()
    local val, err = n.parse('42')
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'invalid_type')
  end)

  T.it('enforces min value', function()
    local n = prism:number()
    n.min(10)
    local val, err = n.parse(5)
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'too_small')
  end)

  T.it('enforces max value', function()
    local n = prism:number()
    n.max(10)
    local val, err = n.parse(15)
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'too_big')
  end)

  T.it('applies default when nil', function()
    local n = prism:number()
    n.default(99)
    local val, err = n.parse(nil)
    T.eq(val, 99)
    T.falsy(err)
  end)

  T.it('does NOT overwrite provided number with default', function()
    local n = prism:number()
    n.default(99)
    local val, err = n.parse(7)
    T.eq(val, 7)
    T.falsy(err)
  end)
end)

-- =============================================================================
-- BOOLEAN BUILDER
-- =============================================================================

T.describe('prism:boolean()', function()
  T.it('parses true', function()
    local b = prism:boolean()
    local val, err = b.parse(true)
    T.eq(val, true)
    T.falsy(err)
  end)

  T.it('parses false', function()
    local b = prism:boolean()
    local val, err = b.parse(false)
    T.eq(val, false)
    T.falsy(err)
  end)

  T.it('rejects non-boolean', function()
    local b = prism:boolean()
    local val, err = b.parse('true')
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'invalid_type')
  end)
end)

-- =============================================================================
-- ENUM BUILDER
-- =============================================================================

T.describe('prism:enum()', function()
  T.it('accepts a valid enum value', function()
    local e = prism:enum({ 'a', 'b', 'c' })
    local val, err = e.parse('b')
    T.eq(val, 'b')
    T.falsy(err)
  end)

  T.it('rejects an invalid enum value', function()
    local e = prism:enum({ 'a', 'b', 'c' })
    local val, err = e.parse('d')
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'invalid_enum')
  end)

  T.it('rejects empty enum list', function()
    T.throws(function()
      prism:enum({})
    end)
  end)
end)

-- =============================================================================
-- OBJECT BUILDER
-- =============================================================================

T.describe('prism:object()', function()
  T.it('parses a valid object', function()
    local o = prism:object({
      name = prism:string(),
      age = prism:number(),
    })
    local val, err = o.parse({ name = 'John', age = 25 })
    T.eq(val.name, 'John')
    T.eq(val.age, 25)
    T.falsy(err)
  end)

  T.it('reports error on missing required field', function()
    local o = prism:object({
      name = prism:string(),
      age = prism:number(),
    })
    local val, err = o.parse({ name = 'John' })
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'required')
    T.eq(err.path, 'age')
  end)

  T.it('strips undefined fields by default', function()
    local o = prism:object({
      name = prism:string(),
    })
    local val, err = o.parse({ name = 'John', extra = 'removed' })
    T.eq(val.name, 'John')
    T.eq(val.extra, nil)
    T.falsy(err)
  end)

  T.it('passes through undefined fields with catchall', function()
    local o = prism:object({
      name = prism:string(),
    })
    o.catchall()
    local val, err = o.parse({ name = 'John', extra = 'kept' })
    T.eq(val.name, 'John')
    T.eq(val.extra, 'kept')
    T.falsy(err)
  end)

  T.it('validates nested objects', function()
    local o = prism:object({
      user = prism:object({
        name = prism:string(),
      }),
    })
    local val, err = o.parse({ user = { name = 'John' } })
    T.eq(val.user.name, 'John')
    T.falsy(err)
  end)

  T.it('reports nested path on error', function()
    local o = prism:object({
      user = prism:object({
        name = prism:string(),
      }),
    })
    local val, err = o.parse({ user = { name = 123 } })
    T.falsy(val)
    T.truthy(err)
    T.eq(err.path, 'user.name')
  end)

  T.it('rejects arrays as objects', function()
    local o = prism:object({
      name = prism:string(),
    })
    local val, err = o.parse({ 'a', 'b', 'c' })
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'invalid_type')
  end)
end)

-- =============================================================================
-- EXTENDS
-- =============================================================================

T.describe('prism:extends()', function()
  T.it('extends an existing object schema', function()
    local base = prism:object({
      name = prism:string(),
    })
    local extended = prism:extends(base, {
      age = prism:number(),
    })
    local val, err = extended.parse({ name = 'John', age = 25 })
    T.eq(val.name, 'John')
    T.eq(val.age, 25)
    T.falsy(err)
  end)
end)

-- =============================================================================
-- ARRAY BUILDER
-- =============================================================================

T.describe('prism:array()', function()
  T.it('parses a valid array of strings', function()
    local a = prism:array(prism:string())
    local val, err = a.parse({ 'a', 'b', 'c' })
    T.eq(#val, 3)
    T.eq(val[1], 'a')
    T.falsy(err)
  end)

  T.it('reports error for invalid element', function()
    local a = prism:array(prism:number())
    local val, err = a.parse({ 1, 'bad', 3 })
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'invalid_type')
    T.eq(err.path, '2')
  end)

  T.it('enforces min length', function()
    local a = prism:array(prism:string())
    a.min(3)
    local val, err = a.parse({ 'a' })
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'too_small')
  end)

  T.it('enforces max length', function()
    local a = prism:array(prism:string())
    a.max(2)
    local val, err = a.parse({ 'a', 'b', 'c' })
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'too_big')
  end)

  T.it('rejects objects as arrays', function()
    local a = prism:array(prism:string())
    local val, err = a.parse({ name = 'John' })
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'invalid_type')
  end)

  T.it('rejects unions in arrays', function()
    T.throws(function()
      prism:array(prism:union({ prism:string(), prism:number() }))
    end)
  end)
end)

-- =============================================================================
-- UNION BUILDER
-- =============================================================================

T.describe('prism:union()', function()
  T.it('accepts string in string|number union', function()
    local u = prism:union({ prism:string(), prism:number() })
    local val, err = u.parse('hello')
    T.eq(val, 'hello')
    T.falsy(err)
  end)

  T.it('accepts number in string|number union', function()
    local u = prism:union({ prism:string(), prism:number() })
    local val, err = u.parse(42)
    T.eq(val, 42)
    T.falsy(err)
  end)

  T.it('rejects boolean in string|number union', function()
    local u = prism:union({ prism:string(), prism:number() })
    local val, err = u.parse(true)
    T.falsy(val)
    T.truthy(err)
    T.eq(err.code, 'invalid_union')
  end)
end)

-- =============================================================================
-- TRANSFORM
-- =============================================================================

T.describe('transform()', function()
  T.it('transforms number values', function()
    local n = prism:number()
    n.transform(function(v) return v * 2 end)
    local val, err = n.parse(5)
    T.eq(val, 10)
    T.falsy(err)
  end)

  T.it('transforms object values', function()
    local o = prism:object({
      name = prism:string(),
    })
    o.transform(function(v)
      v.name = v.name:upper()
      return v
    end)
    local val, err = o.parse({ name = 'john' })
    T.eq(val.name, 'JOHN')
    T.falsy(err)
  end)
end)

-- =============================================================================
-- PLUGIN SYSTEM
-- =============================================================================

T.describe('prism:use() plugin system', function()
  T.it('registers and invokes a plugin', function()
    local invoked = false
    prism:use({
      name = 'test_plugin',
      init = function()
        invoked = true
      end,
    })
    T.truthy(invoked)
  end)

  T.it('prevents duplicate plugin registration', function()
    local count = 0
    prism:use({
      name = 'dedup_test',
      init = function()
        count = count + 1
      end,
    })
    prism:use({
      name = 'dedup_test',
      init = function()
        count = count + 1
      end,
    })
    T.eq(count, 1)
  end)

  T.it('rejects non-table plugin', function()
    T.throws(function()
      prism:use('not a table')
    end)
  end)

  T.it('rejects plugin without name', function()
    T.throws(function()
      prism:use({ init = function() end })
    end)
  end)
end)

-- =============================================================================
-- CUSTOM ERROR MESSAGES
-- =============================================================================

T.describe('custom error messages', function()
  T.it('uses custom invalidTypeMessage', function()
    local s = prism:string({ invalidTypeMessage = 'Must be text!' })
    local val, err = s.parse(123)
    T.falsy(val)
    T.eq(err.message, 'Must be text!')
  end)

  T.it('uses custom requiredErrorMessage', function()
    local s = prism:string({ requiredErrorMessage = 'This field is mandatory!' })
    local val, err = s.parse(nil)
    T.falsy(val)
    T.eq(err.message, 'This field is mandatory!')
  end)
end)

-- =============================================================================
-- UTILITY FUNCTIONS
-- =============================================================================

T.describe('utility functions', function()
  T.it('isArray identifies arrays correctly', function()
    T.truthy(isArray({ 1, 2, 3 }))
    T.truthy(isArray({}))
    T.falsy(isArray({ name = 'John' }))
    T.falsy(isArray('string'))
    T.falsy(isArray(42))
  end)

  T.it('mergeTable merges recursively', function()
    local a = { x = 1, nested = { a = 1 } }
    local b = { y = 2, nested = { b = 2 } }
    local result = mergeTable(a, b)
    T.eq(result.x, 1)
    T.eq(result.y, 2)
    T.eq(result.nested.a, 1)
    T.eq(result.nested.b, 2)
  end)
end)

-- ─── Summary ──────────────────────────────────────────────────────────────────

local all_passed = T.summary()
os.exit(all_passed and 0 or 1)
