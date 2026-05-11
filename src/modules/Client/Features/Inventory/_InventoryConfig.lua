--[=[
    @class InventoryConstants
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local InventoryTypesClient = require("InventoryTypesClient")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryConstants = {
    TabsConfig = {
        ["Garden"] = {
            ["Plant"] = true
        },
        ["Materials"] = {
            ["Material"] = true
        }
    }
} :: {
    TabsConfig: InventoryTypesClient.TabsConfig
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(InventoryConstants) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return InventoryConstants :: Module