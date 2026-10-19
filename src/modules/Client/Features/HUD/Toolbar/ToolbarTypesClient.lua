--[=[
    @class ToolbarTypesClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local ToolbarTypesShared = require("ToolbarTypesShared")
local ValueObject = require("ValueObject")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
-- Fixed slot set (one ValueObject per config slot, created at boot); only
-- the bound item id inside each slot mutates.
export type ReactiveSlots = {
    [ToolbarTypesShared.SlotId]: ValueObject.ValueObject<ItemTypes.ItemId?>
}

return nil
