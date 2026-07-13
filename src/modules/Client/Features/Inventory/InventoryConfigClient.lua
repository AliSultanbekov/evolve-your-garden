--[=[
    @class InventoryConfigClient
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
local InventoryConfigClient = {
    -- Display order of the tabs (TabsConfig is a dict, so it can't carry order).
    TabOrder = { "Garden", "Materials", "Items", "Currencies" },
    TabsConfig = {
        ["Garden"] = {
            ["Plant"] = true,
        },
        ["Materials"] = {
            ["Material"] = true
        },
        ["Items"] = {
            ["Pack"] = true
        },
        ["Currencies"] = {
            ["Currency"] = true
        },
    },
    CategoryToTab = {
        ["Plant"] = "Garden",
        ["Material"] = "Materials",
        ["Pack"] = "Items",
        ["Currency"] = "Currencies"
    }
} :: {
    TabOrder: { string },
    TabsConfig: InventoryTypesClient.TabsConfig,
    CategoryToTab: {
        [ItemTypes.Category]: string
    }
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(InventoryConfigClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return InventoryConfigClient :: Module