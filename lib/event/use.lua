local addEventHandler = AddEventHandler
local registerNetEvent = RegisterNetEvent
local registries = {}

---@class EventPlugin
---@field name string
---@field init fun()
local event_plugin = {
  name = 'event',
  init = function()
    ---@param name string
    ---@param cb fun(...)
    ---@param schema ObjectChainBuilder
    ---@return EventHandler
    _G.AddEventHandler = function(name, cb, schema)
      if type(schema) == 'table' then
        registries[name] = schema
      end

      return addEventHandler(name, function(...)
        local args = { ... }
        if registries[name] then
          local newArgs, errorMessage = registries[name].parse(args)
          if newArgs == nil and errorMessage then
            error(json.encode(errorMessage, { indent = true }))
          end
        end

        cb(table.unpack(args))
      end)
    end

    ---@param name string
    ---@param cb fun(...)
    ---@param schema ObjectChainBuilder
    ---@return EventHandler
    _G.RegisterNetEvent = function(name, cb, schema)
      registerNetEvent(name)
      return AddEventHandler(name, cb, schema)
    end

    ---@param name string
    ---@param cb fun(...)
    ---@param schema ObjectChainBuilder
    ---@return EventHandler
    ---@diagnostic disable-next-line: duplicate-set-field
    _G.RegisterServerEvent = function(name, cb, schema)
      registerNetEvent(name)
      return AddEventHandler(name, cb, schema)
    end

    print('^7Initialized ^3[event] ^7plugin for data validation ^2successfully^7')
  end,
}

-- Auto-register if prism is available
if prism then
  prism:use(event_plugin)
end
