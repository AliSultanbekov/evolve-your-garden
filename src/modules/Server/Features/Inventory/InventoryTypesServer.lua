--[=[
    @class InventoryTypesServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type Gateway = {
    AddRawItems: (items: { [any]: ItemTypes.RawItem }, discover: boolean?, transmitDelay: number?) -> (),
    AddItems: (items: { [any]: ItemTypes.Item }, discover: boolean?, transmitDelay: number?) -> (),
    RemoveItems: (items: { [any]: ItemTypes.Item }) -> (),
    UpdateItems: (items: { [any]: ItemTypes.Item }) -> (),
}

return nil