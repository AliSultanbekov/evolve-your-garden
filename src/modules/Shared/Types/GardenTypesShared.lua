--[=[
    @class GardenTypesShared
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
export type GardenId = string
export type SlotId = string

export type GardenClaimedRemotePacket = {
    GardenId: GardenId,
    UserId: string,
}

export type GardenAbandonedRemotePacket = {
    GardenId: GardenId,
}

export type SlotData = {
    Id: SlotId,
    Plant: ItemTypes.PlantItem?,
    Harvest: {
        [ItemTypes.ItemId]: ItemTypes.Item
    },
}

return nil