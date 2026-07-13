--[=[
    @class GardenTypesShared
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type GardenId = string
export type SlotId = string


-- Server Events
export type Slot = {
    Id: SlotId,
    Plant: ItemTypes.PlantItem?,
    Harvest: {
        [ItemTypes.ItemId]: ItemTypes.Item
    },
    HarvestCount: number,
}

export type Slots = { [SlotId]: Slot }

export type GardenClaimedRemotePacket = {
    GardenId: GardenId,
    UserId: string,
    GardenLevel: number,
    Slots: Slots
}

export type GardenAbandonedRemotePacket = {
    GardenId: GardenId,
}

export type PlantRemovedRemotePacket = {
    GardenId: GardenId,
    SlotId: SlotId,
}

export type PlantPlacedRemotePacket = {
    GardenId: GardenId,
    SlotId: SlotId,
    Plant: ItemTypes.PlantItem,
}

export type PlacePlantRemotePacket = {
    SlotId: SlotId,
    ItemId: ItemTypes.ItemId,
}

export type RemovePlantRemotePacket = {
    SlotId: SlotId,
}

export type GrowthCycleRemotePacket = {
    Growth: {
        [GardenId]: {
            [SlotId]: ItemTypes.PlantItem
        }
    }
}

export type HarvestItemsAddedRemotePacket = {
    GardenId: GardenId,
    Harvest: { [SlotId]: { [any]: ItemTypes.Item } }
}

export type HarvestItemsUpdatedRemotePacket = {
    GardenId: GardenId,
    Harvest: { [SlotId]: { [any]: ItemTypes.Item } }
}

export type HarvestCollectedRemotePacket = {
    GardenId: GardenId,
    SlotId: SlotId,
}

-- Client Events
export type GetGardensRemotePacket = {
    Gardens: {
        [GardenId]: {
            Id: GardenId,
            Owner: string,
            Level: number,
            Slots: Slots
        }
    }
}

export type CollectHarvestRemotePacket = {
    SlotId: SlotId,
}

return nil