--[=[
    @class GardenWorldClient
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local GardenTypesShared = require("GardenTypesShared")
local GardenTypesClient = require("GardenTypesClient")

local GardenComponent = require(script.Parent.Garden._GardenComponent)

-- [ Constants ] --

-- [ Variables ] --
local LocalPlayer = Players.LocalPlayer

-- [ Module Table ] --
local GardenWorldClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _GardenServiceClient: typeof(require("GardenServiceClient")),
    _MouseServiceClient: typeof(require("MouseServiceClient")),
    _Maid: Maid.Maid,
}

export type Module = typeof(GardenWorldClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function GardenWorldClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._GardenServiceClient = self._ServiceBag:GetService(require("GardenServiceClient"))
    self._MouseServiceClient = self._ServiceBag:GetService(require("MouseServiceClient"))
    self._Maid = Maid.new()
end

function GardenWorldClient.Start(self: Module)
    local Gardens = self._GardenServiceClient:GetGardens()

    for _, garden in pairs(Gardens) do
        self._Maid:Add(GardenComponent({
            MouseServiceClient = self._MouseServiceClient;

            Garden = garden;
            
            OnSlotSelected = function(slotId: GardenTypesShared.SlotId)
                self._GardenServiceClient:SelectSlot(slotId)
            end,
            OnSlotCreated = function(slotId: GardenTypesShared.SlotId, slotModel: GardenTypesClient.SlotModel)
                self._GardenServiceClient:RegisterSlotModel(slotId, slotModel)
            end,
            OnSlotDestroyed = function(slotId: GardenTypesShared.SlotId)
                self._GardenServiceClient:UnregisterSlotModel(slotId)
            end
        }))
    end

    self._Maid:Add(RunService.Heartbeat:Connect(function(dt: number)
        local SlotModels = self._GardenServiceClient:GetSlotModels()
        local Character = LocalPlayer.Character

        if not Character then
            return
        end

        local CharacterCFrame = Character:GetPivot()
        
        local ClosestModel
        local ClosestDistance

        for slotId, slotModel in SlotModels do
            local SlotModelCFrame = slotModel:GetPivot()
            local Distance = (CharacterCFrame.Position - SlotModelCFrame.Position).Magnitude
            
            if Distance > 8 then
                continue
            end

            if ClosestDistance and  ClosestDistance < Distance then
                continue
            end

            ClosestModel = slotModel
            ClosestDistance = Distance
        end

        self._GardenServiceClient:SetClosestSlotModel(ClosestModel)
    end))
end

return GardenWorldClient :: Module