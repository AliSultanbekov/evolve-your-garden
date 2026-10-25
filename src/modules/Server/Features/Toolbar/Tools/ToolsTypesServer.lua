--[=[
    @class ToolsTypesServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local ToolsTypesShared = require("ToolsTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type OnEquippedContext = {
    State: ToolsTypesShared.ToolState,
    Item: ItemTypes.Item,
}

export type OnActivatedContext = {
    State: ToolsTypesShared.ToolState,
    Item: ItemTypes.Item,
    -- Built by the client behavior's ServerParams: an untrusted claim.
    -- The behavior must typecheck every field it reads.
    Params: { [string]: any },
}

export type OnUnequippedContext = {
    State: ToolsTypesShared.ToolState,
    Item: ItemTypes.Item,
}

return nil
