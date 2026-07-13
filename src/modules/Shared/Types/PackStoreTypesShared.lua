--[=[
    @class PackStoreTypesShared
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type PackId = string
export type SaleId = string
export type Category = "Normal" | "Special" | "Event"

export type Pack = {
    Id: PackId,
    Category: Category,
    Name: string,
    Stock: number,
    Left: number,
}

export type Packs = {
    [PackId]: Pack
}

export type PackStore = {
    SaleId: SaleId,
    Packs: Packs
}

export type GlobalPacks = {
    [PackId]: Pack
}

export type SaleState = {
    SaleId: SaleId,
    GlobalPacks: GlobalPacks,
    StartTime: number,
}

export type RefreshedRemotePacket = {
    Packs: Packs,
    StartTime: number,
}

export type GetCurrentSaleRemotePacket = {
    Packs: Packs,
    StartTime: number,
}

export type BuyPackRemotePacket = {
    PackId: PackId
}

export type PackBoughtRemotePacket = {
    PackId: PackId,
    Left: number,
}

return nil