--[=[
    @class InventoryTypesClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local ReactiveItemTypes = require("ReactiveItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type FilteredItems = {
    [string]: ReactiveItemTypes.ReactiveItems
}
export type TabsConfig = {
    [string]: {
        [ItemTypes.Category]: boolean
    }
}
export type Actions = {
    [string]: (...any) -> (...any)
}

return nil