--[=[
    @class InventoryConstants
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local InventoryTypesClient = require("InventoryTypesClient")
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryConstants = {
    TabsConfig = {
        ["Garden"] = {
            ["Plant"] = true,
            ["Currency"] = true
        },
        ["Materials"] = {
            ["Material"] = true
        }
    },
    CategoryToTab = {
        ["Currency"] = "Garden",
        ["Plant"] = "Garden",
        ["Material"] = "Materials",
    }
} :: {
    TabsConfig: InventoryTypesClient.TabsConfig,
    CategoryToTab: {
        [ItemTypes.Category]: string
    }
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(InventoryConstants) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return InventoryConstants :: Module