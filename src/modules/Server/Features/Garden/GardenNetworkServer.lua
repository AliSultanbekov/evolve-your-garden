--[=[
    @class GardenNetworkServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local GardenTypesShared = require("GardenTypesShared")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GardenNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {
        PlacePlant: Signal.Signal<Player, GardenTypesShared.PlacePlantRemotePacket>,
        RemovePlant: Signal.Signal<Player, GardenTypesShared.RemovePlantRemotePacket>,
        CollectHarvest: Signal.Signal<Player, GardenTypesShared.CollectHarvestRemotePacket>,
    },
    RemoteFunctions: {
        GetGardens: () -> GardenTypesShared.GetGardensRemotePacket
    }
}

export type Module = typeof(GardenNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function GardenNetworkServer.HarvestCollected(self: Module, packet: GardenTypesShared.HarvestCollectedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:FireAllClients("HarvestCollected", packet)
end

function GardenNetworkServer.GrowthCycle(self: Module, packet: GardenTypesShared.GrowthCycleRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:FireAllClients("GrowthCycle", packet)
end

function GardenNetworkServer.HarvestItemsUpdated(self: Module, player: Player, packet: GardenTypesShared.HarvestItemsUpdatedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:FireClient("HarvestItemsUpdated", player, packet)
end

function GardenNetworkServer.HarvestItemsAdded(self: Module, player: Player, packet: GardenTypesShared.HarvestItemsAddedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:FireClient("HarvestItemsAdded", player, packet)
end

function GardenNetworkServer.PlantPlaced(self: Module, packet: GardenTypesShared.PlantPlacedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:FireAllClients("PlantPlaced", packet)
end

function GardenNetworkServer.PlantRemoved(self: Module, packet: GardenTypesShared.PlantRemovedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:FireAllClients("PlantRemoved", packet)
end

function GardenNetworkServer.GardenClaimed(self: Module, packet: GardenTypesShared.GardenClaimedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:FireAllClients("GardenClaimed", packet)
end

function GardenNetworkServer.GardenAbandoned(self: Module, packet: GardenTypesShared.GardenAbandonedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:FireAllClients("GardenAbandoned", packet)
end

function GardenNetworkServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceShared = self._ServiceBag:GetService(require("NetworkServiceShared"))

    self.RemoteEvents = {
        PlacePlant = Signal.new(),
        RemovePlant = Signal.new(),
        CollectHarvest = Signal.new(),
    } :: any

    self.RemoteFunctions = {
        
    } :: any
end

function GardenNetworkServer.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:DeclareEvent("PlantPlaced")
    Channel:DeclareEvent("PlantRemoved")
    Channel:DeclareEvent("GardenClaimed")
    Channel:DeclareEvent("GardenAbandoned")
    Channel:DeclareEvent("HarvestItemsAdded")
    Channel:DeclareEvent("HarvestItemsUpdated")
    Channel:DeclareEvent("GrowthCycle")
    Channel:DeclareMethod("GetGardens")
    Channel:DeclareEvent("CollectHarvest")
    Channel:DeclareEvent("HarvestCollected")

    Channel:Connect("PlacePlant", function(player: Player, packet: GardenTypesShared.PlacePlantRemotePacket)
        if typeof(packet) ~= "table" or typeof(packet.SlotId) ~= "string" or typeof(packet.ItemId) ~= "string" then
            return
        end

        self.RemoteEvents.PlacePlant:Fire(player, packet)
    end)

    Channel:Connect("RemovePlant", function(player: Player, packet: GardenTypesShared.RemovePlantRemotePacket)
        if typeof(packet) ~= "table" or typeof(packet.SlotId) ~= "string" then
            return
        end

        self.RemoteEvents.RemovePlant:Fire(player, packet)
    end)

    Channel:Connect("CollectHarvest", function(player: Player, packet: GardenTypesShared.CollectHarvestRemotePacket)
        if typeof(packet) ~= "table" or typeof(packet.SlotId) ~= "string" then
            return
        end

        self.RemoteEvents.CollectHarvest:Fire(player, packet)
    end)

    Channel:Bind("GetGardens", function(player: Player, packet: GardenTypesShared.GetGardensRemotePacket)
        return self.RemoteFunctions.GetGardens()
    end)
end

return GardenNetworkServer :: Module