--[=[
    @class InventoryTypesShared
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --

export type ItemsRemovedRemotePacket = {
    Items: { [any]: ItemTypes.Item }
}
export type ItemsAddedRemotePacket = {
    Items: { [any]: ItemTypes.Item }
}
export type ItemsUpdatedRemotePacket = {
    Items: { [any]: ItemTypes.Item },
}
export type GetItemsRemotePacket = {
    Items: { [any]: ItemTypes.Item },
}
export type UseActionRemotePacket = {
    Action: string,
    ItemId: ItemTypes.ItemId,
    Params: { [string]: any }?
}

export type Action = "Open" | "Delete"

export type Result = "Success" | "Fail"

return nil