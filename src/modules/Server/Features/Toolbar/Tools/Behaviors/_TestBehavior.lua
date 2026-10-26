--[=[
    @class TestBehavior
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local ToolsTypesServer = require("ToolsTypesServer")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local TestBehavior = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(TestBehavior) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function TestBehavior.OnEquipped(self: Module, player: Player, maid: Maid.Maid, context: ToolsTypesServer.OnEquippedContext)

end

function TestBehavior.OnActivated(self: Module, player: Player, context: ToolsTypesServer.OnActivatedContext)

end

function TestBehavior.OnUnequipped(self: Module, player: Player, context: ToolsTypesServer.OnUnequippedContext)
    print("Item Unequipped")
end

return TestBehavior :: Module