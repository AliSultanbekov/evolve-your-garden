--[=[
    @class GardenServiceClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local GardenConstants = require("GardenConstants")
local ValueObject = require("ValueObject")
local GardenTypesShared = require("GardenTypesShared")
local GardenTypesClient = require("GardenTypesClient")
local ObservableMap = require("ObservableMap")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GardenServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _GardenNetworkClient: typeof(require("GardenNetworkClient")),
    _Gardens: GardenTypesClient.ReactiveGardens,
    _SelectedSlot: ValueObject.ValueObject<GardenTypesShared.SlotId?>
}

export type Module = typeof(GardenServiceClient) & ModuleData

-- [ Private Functions ] --
function GardenServiceClient.SlotToReactiveSlot(self: Module, slot: GardenTypesShared.Slot): GardenTypesClient.ReactiveSlot
    return {
        Id = slot.Id,
        Plant = ValueObject.new(slot.Plant),
        Harvest = ObservableMap.new(),
    }
end

function GardenServiceClient.AddSlotsToMap(self: Module, map: GardenTypesClient.ReactiveSlots, slots: GardenTypesShared.Slots)
    for _, slot in slots do
        map:Set(slot.Id, self:SlotToReactiveSlot(slot))
    end
end

function GardenServiceClient._SetupGardens(self: Module)
    local Gardens = {}

    for i = 1, GardenConstants.MaxGardens do
        local GardenId = tostring(i)

        Gardens[GardenId] = {
            GardenId = GardenId,
            Owner = ValueObject.new(nil),
            Level = ValueObject.new(nil),
            Slots = ObservableMap.new()
        }
    end

    return Gardens
end

-- [ Public Functions ] --
function GardenServiceClient.GetGardens(self: Module): GardenTypesClient.ReactiveGardens
    return self._Gardens
end

function GardenServiceClient.ObserveSelectedSlot(self: Module)
    return self._SelectedSlot:Observe()
end

function GardenServiceClient.SelectSlot(self: Module, SlotId: GardenTypesShared.SlotId?)
    self._SelectedSlot.Value = SlotId
end

function GardenServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._GardenNetworkClient = self._ServiceBag:GetService(require("GardenNetworkClient"))
    self._Gardens = self:_SetupGardens()
    self._SelectedSlot = ValueObject.new(nil)
end

function GardenServiceClient.Start(self: Module)
    self._GardenNetworkClient.RemoteEvents.GardenClaimed:Connect(function(packet: GardenTypesShared.GardenClaimedRemotePacket)
        local Garden = self._Gardens[packet.GardenId]
        Garden.Owner.Value = packet.UserId
        Garden.Level.Value = packet.GardenLevel
        
        self:AddSlotsToMap(Garden.Slots, packet.Slots)
    end)

    self._GardenNetworkClient.RemoteEvents.GardenAbandoned:Connect(function(packet: GardenTypesShared.GardenAbandonedRemotePacket)
        local Garden = self._Gardens[packet.GardenId]
        Garden.Owner.Value = nil
        Garden.Level.Value = nil
    end)
end

return GardenServiceClient :: Module