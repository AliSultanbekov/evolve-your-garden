--[=[
    @class ToolsTypesClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ReactiveItemTypes = require("ReactiveItemTypes")
local ToolsTypesShared = require("ToolsTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Types ] --
export type BehaviorOnEquippedContext = {
    State: ToolsTypesShared.ToolState,
    Item: ReactiveItemTypes.ReactiveItem
}

return nil