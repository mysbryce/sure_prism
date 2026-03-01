---
name: FiveM Resource Development with ox_lib and ESX
description: Core guidelines for Claude to develop FiveM resources using ox_lib, ESX, EmmyLua types, and standard Lua 5.4 modular structuring.
---

# FiveM Development Guidelines

When working on this project or generating code, you **MUST** strictly adhere to the following rules and structural guidelines:

## 1. Core Frameworks & Dependencies
- **ox_lib:** You must rely completely on `ox_lib` for generic utility functions, iterations, zones, UI elements (if applicable), and basic framework wrappers. Reference: [ox_lib Docs](https://coxdocs.dev/ox_lib).
- **ESX Framework:** Whenever you need to interact with the Player Class, retrieve character data, inventory, or jobs, use ESX. Reference: [ESX Docs](https://docs.esx-framework.org/en).
- **Lua Environment:** Treat the environment as **Lua 5.4**. Always define `lua54 'yes'` in the `fxmanifest.lua` file.

## 2. Directory & Architecture Structure
Follow a modular architecture pattern:
- The main entry points must be `client/init.lua` and `server/init.lua`.
- Create sub-folders (e.g., `client/modules`, `server/events`) to store respective modular files, which will be logically `require`d by the `init.lua` files.

## 3. Configuration Management
Configuration files must be placed into specific directories to prevent leakage of server-side data:
- **`config/public/`**: Place configs here if they are used by the **Client only** or shared across **Client + Server**.
- **`config/secret/`**: Place configs here if they are used by the **Server only**.

## 4. Coding Standards & Naming Conventions
- **Naming Pattern:** You must define all variables and properties using the `snake_case` pattern (e.g., `name_is_name`, `this_is_a_variable`).
- **Language Policy:** Do **NOT** write comments in Thai. All comments, docstrings, and explanations **must be exclusively in English**.

## 5. Type Safety (EmmyLua)
- You must define **EmmyLua Types for EVERYTHING**. This includes variables, function parameters, returns, arrays, and complex objects.
- **Module Export Pattern:** For any file that will be required by another file, define the module as a strongly-typed class using the following exact pattern:

```lua
---@class NamespaceOrResourceName.SomeClass
local MODULE_NAME = {}

---@type string
MODULE_NAME.some_config_with_this_var_name_type = ''

return MODULE_NAME
```

## 6. User Interfaces (UI)
- For any resource component that would traditionally require a custom User Interface (NUI browser instances, HTML/JS/CSS), **DO NOT implement a UI**. 
- Instead, simulate the UI interactions and flows entirely by using **Commands** (and standard `ox_lib` dialogs/textui if strictly necessary to facilitate the command-based flow).
