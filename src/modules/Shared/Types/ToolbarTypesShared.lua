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

export type ToolbarData = {
    [SlotId]: ItemTypes.ItemId,
}

return nil