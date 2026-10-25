--[=[
    @class ToolsTypesClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ToolsTypesShared = require("ToolsTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type OnEquippedContext = {
    ServiceBag: ServiceBag.ServiceBag,
    State: ToolsTypesShared.ToolState,
    Item: ReactiveItemTypes.ReactiveItem,
}

export type OnActivatedContext = {
    ServiceBag: ServiceBag.ServiceBag,
    State: ToolsTypesShared.ToolState,
    Item: ReactiveItemTypes.ReactiveItem,
    -- Filled by the behavior; sent as-is to the server behavior. Intent only:
    -- ids and clamped values, never client-owned state.
    ServerParams: { [string]: any },
}

export type OnUnequippedContext = {
    ServiceBag: ServiceBag.ServiceBag,
    State: ToolsTypesShared.ToolState,
    Item: ReactiveItemTypes.ReactiveItem,
}

return nil
