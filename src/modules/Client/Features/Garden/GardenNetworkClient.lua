--[=[
    @class GardenNetworkClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")
local GardenTypesShared = require("GardenTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GardenNetworkClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {
        PlantPlaced: Signal.Signal<GardenTypesShared.PlantPlacedRemotePacket>,
        PlantRemoved: Signal.Signal<GardenTypesShared.PlantRemovedRemotePacket>,
        GardenClaimed: Signal.Signal<GardenTypesShared.GardenClaimedRemotePacket>,
        GardenAbandoned: Signal.Signal<GardenTypesShared.GardenAbandonedRemotePacket>,
    },
    RemoteFunctions: {}
}

export type Module = typeof(GardenNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function GardenNetworkClient.RemovePlant(self: Module, packet: GardenTypesShared.RemovePlantRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:FireServer("RemovePlant", packet)
end

function GardenNetworkClient.PlacePlant(self: Module, packet: GardenTypesShared.PlacePlantRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:FireServer("PlacePlant", packet)
end

function GardenNetworkClient.GetGardens(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    return Channel:PromiseInvokeServer("GetGardens")
end

function GardenNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceShared = self._ServiceBag:GetService(require("NetworkServiceShared"))

    self.RemoteEvents = {
        PlantPlaced = Signal.new(),
        PlantRemoved = Signal.new(),
        GardenClaimed = Signal.new(),
        GardenAbandoned = Signal.new()
    } :: any

    self.RemoteFunctions = {
        
    } :: any
end

function GardenNetworkClient.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:Connect("PlantPlaced", function(packet: GardenTypesShared.PlantPlacedRemotePacket)
        self.RemoteEvents.PlantPlaced:Fire(packet)
    end)

    Channel:Connect("PlantRemoved", function(packet: GardenTypesShared.PlantRemovedRemotePacket)
        self.RemoteEvents.PlantRemoved:Fire(packet)
    end)

    Channel:Connect("GardenClaimed", function(packet: GardenTypesShared.GardenClaimedRemotePacket)
        self.RemoteEvents.GardenClaimed:Fire(packet)
    end)

    Channel:Connect("GardenAbandoned", function(packet: GardenTypesShared.GardenAbandonedRemotePacket)
        self.RemoteEvents.GardenAbandoned:Fire(packet)
    end)
end

return GardenNetworkClient :: Module