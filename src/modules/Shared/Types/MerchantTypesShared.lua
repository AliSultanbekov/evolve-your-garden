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

-- Fields are nil until the first server Refresh fills them (the profile
-- template ships an empty Merchant table).
export type Merchant = {
    LastRefresh: number?,
    BuySlots: Slots?
}

export type GetBuySlotsRemotePacket = {
    BuySlots: Slots?,
    LastRefresh: number?,
}

export type RefreshedRemotePacket = {
    BuySlots: Slots,
    LastRefresh: number,
}

export type BoughtRemotePacket = {
    SlotId: SlotId,
    Left: number,
}

export type BuyRemotePacket = {
    SlotId: SlotId,
}

export type SellRemotePacket = {
    ItemId: string,
    Amount: number,
}



return nil