--[=[
    @class GardenServiceClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local GardenTypesShared = require("GardenTypesShared")
local GardenTypesClient = require("GardenTypesClient")
local ValueObject = require("ValueObject")
local GardenConfig = require("GardenConfig")
local ObservableMap = require("ObservableMap")
local ReactiveItemUtil = require("ReactiveItemUtil")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GardenServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _GardenNetworkClient: typeof(require("GardenNetworkClient")),
    _Gardens: GardenTypesClient.ReactiveGardens,
    _GardenModels: { [GardenTypesShared.GardenId]: GardenTypesClient.GardenModel },
    _SlotModels: { [GardenTypesShared.GardenId]: { [GardenTypesShared.SlotId]: GardenTypesClient.SlotModel} },
    _SelectedSlotInfo: ValueObject.ValueObject<GardenTypesClient.SlotInfo?>,
    _HoveredSlotInfo: ValueObject.ValueObject<GardenTypesClient.SlotInfo?>,
}

export type Module = typeof(GardenServiceClient) & ModuleData

-- [ Private Functions ] --
function GardenServiceClient._SlotToReactiveSlot(self: Module, slot: GardenTypesShared.Slot): GardenTypesClient.ReactiveSlot
    local Plant = if slot.Plant then ReactiveItemUtil:ToReactive(slot.Plant) else nil

    return {
        Id = slot.Id,
        Plant = ValueObject.new(Plant),
        Harvest = ObservableMap.new(),
    }
end

function GardenServiceClient._AddSlotsToMap(self: Module, map: GardenTypesClient.ReactiveSlots, slots: GardenTypesShared.Slots)
    for _, slot in slots do
        map:Set(slot.Id, self:_SlotToReactiveSlot(slot))
    end
end 

function GardenServiceClient._SetupGardens(self: Module): GardenTypesClient.ReactiveGardens
    local Gardens = {}

    for i = 1, GardenConfig.MaxGardens do
        local GardenId = tostring(i)

        Gardens[GardenId] = {
            Id = GardenId,
            Owner = ValueObject.new(nil),
            Level = ValueObject.new(nil),
            Slots = ObservableMap.new(),
        }
    end

    return Gardens
end

-- [ Public Functions ] --
function GardenServiceClient.GetGardens(self: Module)
    return self._Gardens
end

function GardenServiceClient.GetSlotModel(self: Module, gardenId: GardenTypesShared.GardenId, slotId: GardenTypesShared.SlotId)
    local Models = self._SlotModels[gardenId]

    return Models and Models[slotId]
end

function GardenServiceClient.RegisterSlotModel(
    self: Module, 
    gardenId: GardenTypesShared.GardenId, 
    slotId: GardenTypesShared.SlotId, 
    model: GardenTypesClient.GardenModel
)
    self._SlotModels[gardenId] = self._SlotModels[gardenId] or {}
    self._SlotModels[gardenId][slotId] = model
end

function GardenServiceClient.UnregisterSlotModel(
    self: Module, 
    gardenId: GardenTypesShared.GardenId, 
    slotId: GardenTypesShared.SlotId
)
    local Models = self._SlotModels[gardenId]

    if Models then
        Models[slotId] = nil
    end
end

function GardenServiceClient.GetGardenModel(self: Module, gardenId: GardenTypesShared.GardenId)
    return self._GardenModels[gardenId]
end

function GardenServiceClient.RegisterGardenModel(self: Module, gardenId: GardenTypesShared.GardenId, model: GardenTypesClient.GardenModel)
    self._GardenModels[gardenId] = model
end

function GardenServiceClient.UnregisterGardenModel(self: Module, gardenId: GardenTypesShared.GardenId)
    self._GardenModels[gardenId] = nil
end

function GardenServiceClient.GetSlot(self: Module, gardenId: GardenTypesShared.GardenId, slotId: GardenTypesShared.SlotId)
    return self._Gardens[gardenId].Slots:Get(slotId)
end

function GardenServiceClient.HoverSlotInfo(self: Module, slotInfo: GardenTypesClient.SlotInfo?)
    self._HoveredSlotInfo.Value = slotInfo
end

function GardenServiceClient.SelectSlotInfo(self: Module, slotInfo: GardenTypesClient.SlotInfo?)
    self._SelectedSlotInfo.Value = slotInfo
end

function GardenServiceClient.GetHoveredSlotInfo(self: Module)
    return self._HoveredSlotInfo.Value
end

function GardenServiceClient.GetSelectedSlotInfo(self: Module)
    return self._SelectedSlotInfo.Value
end

function GardenServiceClient.ObserveHoveredSlotInfo(self: Module)
    return self._HoveredSlotInfo:Observe()
end

function GardenServiceClient.ObserveSelectedSlotInfo(self: Module)
    return self._SelectedSlotInfo:Observe()
end

function GardenServiceClient.PlacePlant(self: Module, slotId: GardenTypesShared.SlotId, itemId: ItemTypes.ItemId)
    self._GardenNetworkClient:PlacePlant({
        SlotId = slotId,
        ItemId = itemId,
    })
end

function GardenServiceClient.RemovePlant(self: Module, slotId: GardenTypesShared.SlotId)
    self._GardenNetworkClient:RemovePlant({
        SlotId = slotId,
    })
end

function GardenServiceClient._ClearSlotInfoForGarden(self: Module, gardenId: GardenTypesShared.GardenId)
    if self._HoveredSlotInfo.Value and self._HoveredSlotInfo.Value.GardenId == gardenId then
        self._HoveredSlotInfo.Value = nil
    end

    if self._SelectedSlotInfo.Value and self._SelectedSlotInfo.Value.GardenId == gardenId then
        self._SelectedSlotInfo.Value = nil
    end
end

function GardenServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._GardenNetworkClient = self._ServiceBag:GetService(require("GardenNetworkClient"))
    self._Gardens = self:_SetupGardens()
    self._GardenModels = {}
    self._SlotModels = {}
    self._SelectedSlotInfo = ValueObject.new()
    self._HoveredSlotInfo = ValueObject.new()
end

function GardenServiceClient.Start(self: Module)
    self._GardenNetworkClient:GetGardens():Then(function(packet: GardenTypesShared.GetGardensRemotePacket)
        for _, garden in packet.Gardens do
            local Garden = self._Gardens[garden.Id]
            Garden.Level.Value = garden.Level
            Garden.Owner.Value = garden.Owner

            self:_AddSlotsToMap(Garden.Slots, garden.Slots)
        end
    end)

    self._GardenNetworkClient.RemoteEvents.GardenClaimed:Connect(function(packet: GardenTypesShared.GardenClaimedRemotePacket)
        local Garden = self._Gardens[packet.GardenId]
        Garden.Owner.Value = packet.UserId
        Garden.Level.Value = packet.GardenLevel

        self:_AddSlotsToMap(Garden.Slots, packet.Slots)

        -- Only clear interaction state if it pointed into THIS garden (e.g. a
        -- re-claim by a new occupant). Another garden being claimed must not
        -- wipe your current hover/selection.
        self:_ClearSlotInfoForGarden(packet.GardenId)
    end)

    self._GardenNetworkClient.RemoteEvents.GardenAbandoned:Connect(function(packet: GardenTypesShared.GardenAbandonedRemotePacket)
        local Garden = self._Gardens[packet.GardenId]

        Garden.Owner.Value = nil
        Garden.Level.Value = nil

        self:_ClearSlotInfoForGarden(packet.GardenId)
    end)

    self._GardenNetworkClient.RemoteEvents.PlantPlaced:Connect(function(packet: GardenTypesShared.PlantPlacedRemotePacket)
        local Garden = self._Gardens[packet.GardenId]
        local Slot = Garden.Slots:Get(packet.SlotId)

        if not Slot then
            return
        end

        local Plant = ReactiveItemUtil:ToReactive(packet.Plant) :: ReactiveItemTypes.ReactivePlantItem
        Slot.Plant.Value = Plant
    end)

    self._GardenNetworkClient.RemoteEvents.PlantRemoved:Connect(function(packet: GardenTypesShared.PlantRemovedRemotePacket)
        local Garden = self._Gardens[packet.GardenId]
        local Slot = Garden.Slots:Get(packet.SlotId)

        if not Slot then
            return
        end

        Slot.Plant.Value = nil
    end)

    self._GardenNetworkClient.RemoteEvents.GrowthCycle:Connect(function(packet: GardenTypesShared.GrowthCycleRemotePacket)
        for gardenId, plants in packet.Growth do
            local Garden = self._Gardens[gardenId]
            for slotId, plant in plants do
                local Slot = Garden.Slots:Get(slotId)

                if not Slot then
                    continue
                end

                local Plant = Slot.Plant.Value

                if not Plant then
                    continue
                end

                ReactiveItemUtil:SyncFromPlain(Plant, plant)
            end
        end
    end)
end

return GardenServiceClient :: Module