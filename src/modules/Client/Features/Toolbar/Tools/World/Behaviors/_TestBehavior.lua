--[=[
    @class TestBehavior
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local ToolsTypesClient = require("ToolsTypesClient")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local TestBehavior = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(TestBehavior) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function TestBehavior.OnEquipped(self: Module, maid: Maid.Maid, context: ToolsTypesClient.BehaviorOnEquippedContext)
    
end

function TestBehavior.OnActivated(self: Module, context: ToolsTypesClient.BehaviorOnEquippedContext)
    
end

return TestBehavior :: Module