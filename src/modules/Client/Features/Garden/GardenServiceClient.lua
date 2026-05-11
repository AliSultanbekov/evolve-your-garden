--[=[
    @class GardenServiceClient
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local GardenConstants = require("GardenConstants")
local ValueObject = require("ValueObject")
local GardenTypesShared = require("GardenTypesShared")
local GardenTypesClient = require("GardenTypesClient")
local ObservableMap = require("ObservableMap")
local ReactiveItemUtil = require("ReactiveItemUtil")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ItemTypes = require("ItemTypes")
local PlayerToUserId = require("PlayerToUserId")

-- [ Constants ] --

-- [ Variables ] --
local LocalPlayer = Players.LocalPlayer

-- [ Module Table ] --
local GardenServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _GardenNetworkClient: typeof(require("GardenNetworkClient")),
    _Gardens: GardenTypesClient.ReactiveGardens,
    _UserIdToGardenId: { [string]: GardenTypesShared.GardenId },
    _LocalGarden: ValueObject.ValueObject<GardenTypesClient.ReactiveGarden?>,
    _SelectedSlot: ValueObject.ValueObject<GardenTypesShared.SlotId?>,
}

export type Module = typeof(GardenServiceClient) & ModuleData

-- [ Private Functions ] --
function GardenServiceClient._SlotToReactiveSlot(self: Module, slot: GardenTypesShared.Slot): GardenTypesClient.ReactiveSlot
    return {
        Id = slot.Id,
        Plant = ValueObject.new(slot.Plant),
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

    for i = 1, GardenConstants.MaxGardens do
        local GardenId = tostring(i)

        Gardens[GardenId] = {
            GardenId = GardenId,
            Owner = ValueObject.new(nil),
            Level = ValueObject.new(nil),
            Slots = ObservableMap.new(),
        }
    end

    return Gardens
end

-- [ Public Functions ] --
function GardenServiceClient.GetGardens(self: Module): GardenTypesClient.ReactiveGardens
    return self._Gardens
end

function GardenServiceClient.GetGarden(self: Module, gardenId: GardenTypesShared.GardenId): GardenTypesClient.ReactiveGarden?
    return self._Gardens[gardenId]
end

function GardenServiceClient.GetGardenForUser(self: Module, userId: string): GardenTypesClient.ReactiveGarden?
    local GardenId = self._UserIdToGardenId[userId]
    return GardenId and self._Gardens[GardenId] or nil
end

function GardenServiceClient.GetLocalGarden(self: Module): ValueObject.ValueObject<GardenTypesClient.ReactiveGarden?>
    return self._LocalGarden
end

function GardenServiceClient.GetLocalSlot(self: Module, slotId: GardenTypesShared.SlotId): GardenTypesClient.ReactiveSlot?
    local Garden = self._LocalGarden.Value
    return Garden and Garden.Slots:Get(slotId) or nil
end

function GardenServiceClient.ObserveSelectedSlot(self: Module)
    return self._SelectedSlot:Observe()
end

function GardenServiceClient.SelectSlot(self: Module, slotId: GardenTypesShared.SlotId?)
    self._SelectedSlot.Value = slotId
end

function GardenServiceClient.PlacePlant(self: Module, itemId: ItemTypes.ItemId)
    local SelectedSlot = self._SelectedSlot.Value

    if not SelectedSlot then
        return
    end

    self._GardenNetworkClient:PlacePlant({
        SlotId = SelectedSlot,
        ItemId = itemId,
    })

    self:SelectSlot(nil)
end

function GardenServiceClient.RemovePlant(self: Module)
    local SelectedSlot = self._SelectedSlot.Value

    if not SelectedSlot then
        return
    end

    self._GardenNetworkClient:RemovePlant({
        SlotId = SelectedSlot,
    })

    self:SelectSlot(nil)
end

function GardenServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._GardenNetworkClient = self._ServiceBag:GetService(require("GardenNetworkClient"))
    self._Gardens = self:_SetupGardens()
    self._UserIdToGardenId = {}
    self._LocalGarden = ValueObject.new(nil)
    self._SelectedSlot = ValueObject.new(nil)
end

function GardenServiceClient.Start(self: Module)
    local LocalUserId = PlayerToUserId(LocalPlayer)

    self._GardenNetworkClient.RemoteEvents.GardenClaimed:Connect(function(packet: GardenTypesShared.GardenClaimedRemotePacket)
        local Garden = self._Gardens[packet.GardenId]
        Garden.Owner.Value = packet.UserId
        Garden.Level.Value = packet.GardenLevel
        self:_AddSlotsToMap(Garden.Slots, packet.Slots)

        self._UserIdToGardenId[packet.UserId] = packet.GardenId

        if packet.UserId == LocalUserId then
            self._LocalGarden.Value = Garden
        end
    end)

    self._GardenNetworkClient.RemoteEvents.GardenAbandoned:Connect(function(packet: GardenTypesShared.GardenAbandonedRemotePacket)
        local Garden = self._Gardens[packet.GardenId]
        local Owner = Garden.Owner.Value
        Garden.Owner.Value = nil
        Garden.Level.Value = nil

        if Owner then
            self._UserIdToGardenId[Owner] = nil
            if Owner == LocalUserId then
                self._LocalGarden.Value = nil
            end
        end
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
end

return GardenServiceClient :: Module
