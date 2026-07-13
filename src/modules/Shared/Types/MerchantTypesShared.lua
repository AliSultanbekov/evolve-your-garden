--[=[
    @class MerchantTypesShared
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type SlotId = string

export type Slot = {
    Id: SlotId,
    ItemName: string,
    Stock: number,
    Left: number,
}

export type Slots = { [SlotId]: Slot }

export type Merchant = {
    LastRefresh: number,
    BuySlots: Slots
}

export type GetBuySlotsRemotePacket = { 
    BuySlots: Slots 
}

export type RefreshedRemotePacket = {
    BuySlots: Slots
}

export type BoughtRemotePacket = {
    SlotId: SlotId,
}



return nil