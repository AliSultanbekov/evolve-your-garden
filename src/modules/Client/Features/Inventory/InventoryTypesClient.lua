--[=[
    @class InventoryTypesClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ValueObject = require("ValueObject")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type TabToItems = {
    [string]: ReactiveItemTypes.ReactiveItems
}
export type CategoryToItems = {
    [ItemTypes.Category]: ReactiveItemTypes.ReactiveItems
}
export type TabsConfig = {
    [string]: {
        [ItemTypes.Category]: boolean
    }
}
export type Actions = {
    [string]: (...any) -> (...any)
}
export type CollectedItem = {
    Name: string,
    Category: ItemTypes.Category,
    Amount: number,
}
export type CollectedEntry = {
    Name: string,
    Category: ItemTypes.Category,
    Amount: ValueObject.ValueObject<number>,
    IsOpen: ValueObject.ValueObject<boolean>,
    LayoutOrder: number,
}
export type PendingItemEntry = {
    Item: ItemTypes.Item,
    RevealAt: number,
    Thread: thread,
}

return nil