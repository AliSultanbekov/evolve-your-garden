--[=[
    @class GardenNetworkServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local GardenTypesShared = require("GardenTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local GardenNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {},
    RemoteFunctions: {}
}

export type Module = typeof(GardenNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
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

    } :: any

    self.RemoteFunctions = {

    } :: any
end

function GardenNetworkServer.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:DeclareEvent("GardenClaimed")
    Channel:DeclareEvent("GardenAbandoned")
end

return GardenNetworkServer :: Module