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
export type BehaviorContext = {
    State: ToolsTypesShared.ToolState,
    Item: ItemTypes.Item,
}

return nil
