--[=[
    @class InventoryTypesClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ObservableMap = require("ObservableMap")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type Items = ObservableMap.ObservableMap<ItemTypes.ItemId, ReactiveItemTypes.ReactiveItem>
export type FilteredItems = {
    [string]: Items
}
export type TabsConfig = {
    [string]: {
        [ItemTypes.Category]: boolean
    }
}
export type Actions = {
    ["Open"]: (amount: number) -> ()
}

return nil