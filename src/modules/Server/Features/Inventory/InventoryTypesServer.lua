--[=[
    @class InventoryTypesServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local ProfileConfig = require("ProfileConfig")
local GeneralTypesShared = require("GeneralTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type Gateway = {
    AddRawItems: (items: { [any]: ItemTypes.RawItem }, discover: boolean?) -> GeneralTypesShared.DefaultResult,
    AddItems: (items: { [any]: ItemTypes.Item }, discover: boolean?) -> GeneralTypesShared.DefaultResult,
    RemoveItems: (items: { [any]: ItemTypes.Item }) -> (),
    UpdateItems: (items: { [any]: ItemTypes.Item }) -> (),
    IsInventoryFull: () -> boolean,
    CanFitItems: (items: { [any]: ItemTypes.Item }) -> boolean,
}

-- Handed to every item action. Params is the per-action table from the
-- client - an untrusted claim each action validates for itself.
export type ItemActionContext = {
    PlayerData: ProfileConfig.ProfileTemplate,
    Item: ItemTypes.Item,
    Gateway: Gateway,
    Params: { [string]: any },
}

return nil