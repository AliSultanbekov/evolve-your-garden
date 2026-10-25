--[=[
    @class TestBehavior
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local ToolsTypesServer = require("ToolsTypesServer")
local SoundUtil = require("SoundUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local TestBehavior = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(TestBehavior) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function TestBehavior.OnEquipped(self: Module, player: Player, maid: Maid.Maid, context: ToolsTypesServer.BehaviorContext)

end

function TestBehavior.OnActivated(self: Module, player: Player, context: ToolsTypesServer.BehaviorContext)
    print("Item Activated")
end

function TestBehavior.OnUnequipped(self: Module, player: Player, context: ToolsTypesServer.BehaviorContext)
    print("Item Unequipped")
end

return TestBehavior :: Module