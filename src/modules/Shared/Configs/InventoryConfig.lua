--[=[
    @class InventoryConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local InventoryEnums = require("InventoryEnums")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryConfig = {}

-- [ Private Functions ] --
function InventoryConfig._Init(self: Module)
    self.Actions = {
        [InventoryEnums.Actions.Open] = true,
        [InventoryEnums.Actions.Delete] = true,
    }
    self.ServerActions = {
        [InventoryEnums.Actions.UseTool] = true
    }
end

-- [ Public Functions ] --

-- [ Types ] --
type Entry = {
    Name: string,
}

type ModuleData = {
    Actions: {
        [string]: boolean
    },
    ServerActions: {
        [string]: boolean
    },
}

export type Module = typeof(InventoryConfig) & ModuleData

(InventoryConfig :: any):_Init()

return InventoryConfig :: Module