--[=[
    @class MerchantTypesClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local MerchantTypesShared = require("MerchantTypesShared")
local ValueObject = require("ValueObject")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type ReactiveSlot = {
    Id: MerchantTypesShared.SlotId,
    ItemName: ValueObject.ValueObject<string?>,
    Stock: ValueObject.ValueObject<number>,
    Left: ValueObject.ValueObject<number>, 
}

export type ReactiveSlots = {
    [MerchantTypesShared.SlotId]: ReactiveSlot
}

return nil