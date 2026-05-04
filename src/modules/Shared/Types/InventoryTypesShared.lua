--[=[
    @class InventoryTypesShared
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

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
    UpdateInfos: { [ItemTypes.ItemId]: ItemTypes.ItemUpdateInfo }
}

return nil