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
        GardenClaimed: Signal.Signal<GardenTypesShared.GardenClaimedRemotePacket>,
        GardenAbandoned: Signal.Signal<GardenTypesShared.GardenAbandonedRemotePacket>
    },
    RemoteFunctions: {}
}

export type Module = typeof(GardenNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function GardenNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceShared = self._ServiceBag:GetService(require("NetworkServiceShared"))

    self.RemoteEvents = {
        GardenClaimed = Signal.new(),
        GardenAbandoned = Signal.new()
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function GardenNetworkClient.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Garden")

    Channel:Connect("GardenClaimed", function(packet: GardenTypesShared.GardenClaimedRemotePacket)
        self.RemoteEvents.GardenClaimed:Fire(packet)
    end)

    Channel:Connect("GardenAbandoned", function(packet: GardenTypesShared.GardenAbandonedRemotePacket)
        self.RemoteEvents.GardenAbandoned:Fire(packet)
    end)
end

return GardenNetworkClient :: Module