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
function TestBehavior.OnEquipped(self: Module, maid: Maid.Maid, context: ToolsTypesClient.BehaviorContext)
    print("Item Equipped")
end

function TestBehavior.OnActivated(self: Module, context: ToolsTypesClient.BehaviorContext)
    print("Item Activated")
end

function TestBehavior.OnUnequipped(self: Module, context: ToolsTypesClient.BehaviorContext)
    print("Item Unequipped")
end

return TestBehavior :: Module