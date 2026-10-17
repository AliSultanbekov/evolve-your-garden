--[=[
    @class StatsNetworkClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")
local StatsTypesShared = require("StatsTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local StatsNetworkClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {
        StatUpdated: Signal.Signal<StatsTypesShared.StatUpdatedRemotePacket>,
    },
    RemoteFunctions: {}
}

export type Module = typeof(StatsNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function StatsNetworkClient.GetStats(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Stats")

    return Channel:PromiseInvokeServer("GetStats")
end

function StatsNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceShared = self._ServiceBag:GetService(require("NetworkServiceShared"))

    self.RemoteEvents = {
        StatUpdated = Signal.new(),
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function StatsNetworkClient.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Stats")

    Channel:Connect("StatUpdated", function(packet: StatsTypesShared.StatUpdatedRemotePacket)
        self.RemoteEvents.StatUpdated:Fire(packet)
    end)
end

return StatsNetworkClient :: Module
