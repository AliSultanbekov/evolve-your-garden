--[=[
    @class WateringCanBehavior
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local Maid = require("Maid")
local ToolsTypesServer = require("ToolsTypesServer")
local InventoryEnums = require("InventoryEnums")
local ToolsConfig = require("ToolsConfig")
local GeneralEnums = require("GeneralEnums")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WateringCanBehavior = {}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(WateringCanBehavior) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function WateringCanBehavior.OnEquipped(self: Module, player: Player, maid: Maid.Maid, context: ToolsTypesServer.OnEquippedContext)

end

function WateringCanBehavior.OnActivated(self: Module, player: Player, context: ToolsTypesServer.OnActivatedContext)
    local InventoryServiceServer = context.ServiceBag:GetService(require("InventoryServiceServer"))
    local GardenServiceServer = context.ServiceBag:GetService(require("GardenServiceServer"))

    local Item = context.Item

    local ToolConfig = ToolsConfig.Tools[Item.Name]

    if not ToolConfig then
        return
    end

    local GardenId = context.Params.GardenId

    if typeof(GardenId) ~= "string" then
        return
    end

    local SlotId = context.Params.SlotId

    if typeof(SlotId) ~= "string" then
        return
    end
 
    if GardenServiceServer:IsPlantWaterFull(player, GardenId, SlotId) then
        return
    end

    if GardenServiceServer:WaterPlant(player, GardenId, SlotId, ToolConfig.WaterPerUse or ToolsConfig.DefaultWaterPerUse) == GeneralEnums.Result.Fail then
        return
    end

    InventoryServiceServer:UseAction(player, InventoryEnums.Actions.UseTool, context.Item.Id)
end

function WateringCanBehavior.OnUnequipped(self: Module, player: Player, context: ToolsTypesServer.OnUnequippedContext)
    print("Item Unequipped")
end

return WateringCanBehavior :: Module