--[=[
    @class StatsNetworkClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local StatsNetworkClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {},
    RemoteFunctions: {}
}

export type Module = typeof(StatsNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function StatsNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
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

function StatsNetworkClient.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("ChannelName")
end

return StatsNetworkClient :: Module