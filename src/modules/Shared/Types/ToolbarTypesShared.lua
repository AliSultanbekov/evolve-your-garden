--[=[
    @class ToolbarTypesShared
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type SlotId = string
export type Slots = {
    [SlotId]: ItemTypes.ItemId,
}

export type EquipSlotRemotePacket = {
    SlotId: SlotId,
}

export type UnequipSlotRemotePacket = {}

export type BindSlotsRemotePacket = {
    Slots: {
        [SlotId]: ItemTypes.ItemId
    }
}

export type UnbindSlotsRemotePacket = {
    SlotIds: { SlotId }
}

export type GetSlotsRemotePacket = {
    Slots: Slots,
}

return nil