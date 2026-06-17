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
        RemovePlant: Signal.Signal<Player, GardenTypesShared.RemovePlantRemotePacket>
    },
    RemoteFunctions: {
        GetGardens: () -> GardenTypesShared.GetGardensRemotePacket
    }
}

export type Module = typeof(GardenNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function GardenNetworkServer.GrowthCycle(self: Module, packet: GardenTypesShared.GrowthCycleRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:FireAllClients("GrowthCycle", packet)
end

function GardenNetworkServer.HarvestCollected(self: Module, packet: GardenTypesShared.HarvestCollectedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:FireAllClients("HarvestCollected", packet)
end

function GardenNetworkServer.HarvestItemsUpdated(self: Module, player: Player, packet: GardenTypesShared.HarvestItemsUpdatedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:FireAllClients("HarvestItemsUpdated", packet)
end

function GardenNetworkServer.HarvestItemsAdded(self: Module, player: Player, packet: GardenTypesShared.HarvestItemsAddedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:FireAllClients("HarvestItemsAdded", packet)
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
    Channel:DeclareMethod("GetGardens")
    Channel:DeclareEvent("GrowthCycle")

    Channel:Connect("PlacePlant", function(player: Player, packet: GardenTypesShared.PlacePlantRemotePacket)
        self.RemoteEvents.PlacePlant:Fire(player, packet)
    end)

    Channel:Connect("RemovePlant", function(player: Player, packet: GardenTypesShared.RemovePlantRemotePacket)
        self.RemoteEvents.RemovePlant:Fire(player, packet)
    end)
end

return GardenNetworkServer :: Module