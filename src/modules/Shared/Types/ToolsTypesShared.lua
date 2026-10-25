--[=[
    @class ToolsTypesShared
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type ToolState = {
    [any]: any
}

-- Client Events
-- Params carries per-tool activation intent (target slot ids etc.) - ids and
-- clamped values only, never client-owned state. Each server behavior
-- validates its own params shape.
export type ActivateToolRemotePacket = {
    Params: { [string]: any }?,
}

return nil