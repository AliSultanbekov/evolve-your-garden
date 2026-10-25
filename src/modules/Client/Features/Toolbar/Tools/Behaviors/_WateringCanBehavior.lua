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
function TestBehavior.OnEquipped(self: Module, maid: Maid.Maid, context: ToolsTypesClient.OnEquippedContext)

end

function TestBehavior.OnActivated(self: Module, context: ToolsTypesClient.OnActivatedContext)
    local GardenServiceClient = context.ServiceBag:GetService(require("GardenServiceClient"))

    local SlotInfo = GardenServiceClient:GetHoveredSlotInfo()

    if not SlotInfo then
        return
    end

    context.ServerParams.GardenId = SlotInfo.GardenId
    context.ServerParams.SlotId = SlotInfo.SlotId
end

function TestBehavior.OnUnequipped(self: Module, context: ToolsTypesClient.OnUnequippedContext)
    
end

return TestBehavior :: Module