--[=[
    @class ToolsTypesServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local ToolsTypesShared = require("ToolsTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type OnEquippedContext = {
    ServiceBag: ServiceBag.ServiceBag,
    State: ToolsTypesShared.ToolState,
    Item: ItemTypes.Item,
}

export type OnActivatedContext = {
    ServiceBag: ServiceBag.ServiceBag,
    State: ToolsTypesShared.ToolState,
    Item: ItemTypes.Item,
    -- Built by the client behavior's ServerParams: an untrusted claim.
    -- The behavior must typecheck every field it reads.
    Params: { [string]: any },
}

export type OnUnequippedContext = {
    ServiceBag: ServiceBag.ServiceBag,
    State: ToolsTypesShared.ToolState,
    Item: ItemTypes.Item,
}

return nil
