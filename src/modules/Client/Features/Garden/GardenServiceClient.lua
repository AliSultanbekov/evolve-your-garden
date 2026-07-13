--[=[
    @class GardenServiceClient
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

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
local PlayerToUserId = require("PlayerToUserId")
local Rx = require("Rx")

-- [ Constants ] --

-- [ Variables ] --
local LocalPlayer = Players.LocalPlayer
local LocalUserId = PlayerToUserId(LocalPlayer)

-- [ Module Table ] --
local GardenServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _GardenNetworkClient: typeof(require("GardenNetworkClient")),
    _Gardens: GardenTypesClient.ReactiveGardens,
    _UserIdToGardenId: { [string]: GardenTypesShared.GardenId },
    _GardenModels: { [GardenTypesShared.GardenId]: GardenTypesClient.GardenModel },
    _SlotModels: { [GardenTypesShared.GardenId]: { [GardenTypesShared.SlotId]: GardenTypesClient.SlotModel} },
    _SelectedSlotInfo: ValueObject.ValueObject<GardenTypesClient.SlotInfo?>,
    _HoveredSlotInfo: ValueObject.ValueObject<GardenTypesClient.SlotInfo?>,
}

export type Module = typeof(GardenServiceClient) & ModuleData

-- [ Private Functions ] --
function GardenServiceClient._SlotToReactiveSlot(self: Module, slot: GardenTypesShared.Slot): GardenTypesClient.ReactiveSlot
    local Plant = if slot.Plant then ReactiveItemUtil:ToReactive(slot.Plant) else nil
    local Harvest = ObservableMap.new()

    for _, item in slot.Harvest do
        local ReactiveItem = ReactiveItemUtil:ToReactive(item)
        Harvest:Set(item.Id, ReactiveItem)
    end

    return {
        Id = slot.Id,
        Plant = ValueObject.new(Plant),
        Harvest = Harvest,
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
function GardenServiceClient.CollectHarvest(self: Module, slotId: GardenTypesShared.SlotId)
    self._GardenNetworkClient:CollectHarvest({
        SlotId = slotId
    })
end

function GardenServiceClient.ObserveLocalGarden(self: Module)
    local Owners = {}

    for _, garden in pairs(self._Gardens) do
        Owners[garden.Id] = garden.Owner:Observe()
    end

    return Rx.combineLatest(Owners):Pipe({
        Rx.map(function(data)
            for gardenId, owner in data do
                if owner == LocalUserId then
                    return self:GetGarden(gardenId)
                end
            end

            return nil
        end) :: any
    }) :: any
end

function GardenServiceClient.GetLocalGarden(self: Module): GardenTypesClient.ReactiveGarden?
    local UserId = LocalUserId
    local GardenId = self._UserIdToGardenId[UserId]

    return self:GetGarden(GardenId)
end

function GardenServiceClient.GetGarden(self: Module, gardenId: GardenTypesShared.GardenId): GardenTypesClient.ReactiveGarden?
    return self._Gardens[gardenId]
end

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

function GardenServiceClient.GetSelectedSlot(self: Module): GardenTypesClient.ReactiveSlot?
    local SelectedSlotInfo = self._SelectedSlotInfo.Value

    if not SelectedSlotInfo then
        return
    end

    local SelectedSlot = self:GetSlot(SelectedSlotInfo.GardenId, SelectedSlotInfo.SlotId)

    return SelectedSlot
end

function GardenServiceClient.ObserveSelectedSlot(self: Module)
    return self._SelectedSlotInfo:Observe():Pipe({
        Rx.map(function(slotInfo: GardenTypesClient.SlotInfo?)
            if not slotInfo then
                return
            end

            local Slot = self:GetSlot(slotInfo.GardenId, slotInfo.SlotId)

            return Slot
        end) :: any
    }) :: any
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
    self._UserIdToGardenId = {}
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
        self:_ClearSlotInfoForGarden(packet.GardenId)

        self._UserIdToGardenId[packet.UserId] = packet.GardenId
    end)

    self._GardenNetworkClient.RemoteEvents.GardenAbandoned:Connect(function(packet: GardenTypesShared.GardenAbandonedRemotePacket)
        local Garden = self._Gardens[packet.GardenId]

        local Owner = Garden.Owner.Value

        if not Owner then
            return
        end

        Garden.Owner.Value = nil
        Garden.Level.Value = nil

        self:_ClearSlotInfoForGarden(packet.GardenId)

        self._UserIdToGardenId[Owner] = nil
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

    self._GardenNetworkClient.RemoteEvents.HarvestItemsAdded:Connect(function(packet: GardenTypesShared.HarvestItemsAddedRemotePacket)
        local Garden = self._Gardens[packet.GardenId]

        if not Garden then
            return
        end

        for slotId, items in packet.Harvest do
            local Slot = Garden.Slots:Get(slotId)

            if not Slot then
                continue
            end

            for _, item in items do
                Slot.Harvest:Set(item.Id, ReactiveItemUtil:ToReactive(item))
            end
        end
    end)

    self._GardenNetworkClient.RemoteEvents.HarvestItemsUpdated:Connect(function(packet: GardenTypesShared.HarvestItemsAddedRemotePacket)
        local Garden = self._Gardens[packet.GardenId]

        if not Garden then
            return
        end

        for slotId, items in packet.Harvest :: { [GardenTypesShared.SlotId]: { [any]: ItemTypes.StackableItem } } do
            local Slot = Garden.Slots:Get(slotId)

            if not Slot then
                continue
            end

            for _, item in items do
                local ReactiveItem = Slot.Harvest:Get(item.Id) :: ReactiveItemTypes.ReactiveStackableItem?

                if not ReactiveItem then
                    continue
                end

                ReactiveItem.Amount.Value = item.Amount
            end
        end
    end)

    self._GardenNetworkClient.RemoteEvents.HarvestCollected:Connect(function(packet: GardenTypesShared.HarvestCollectedRemotePacket)
        local Garden = self._Gardens[packet.GardenId]

        if not Garden then
            return
        end

        local Slot = Garden.Slots:Get(packet.SlotId)

        if not Slot then
            return
        end

        local Harvest = Slot.Harvest

        for _, key in Harvest:GetKeyList() do
            Harvest:Remove(key)
        end
    end)
end

return GardenServiceClient :: Module