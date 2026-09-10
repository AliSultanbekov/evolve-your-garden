--[=[
    @class EncyclopediaNetworkClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")
local EncyclopediaTypesShared = require("EncyclopediaTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local EncyclopediaNetworkClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {
        ItemDiscovered: Signal.Signal<EncyclopediaTypesShared.ItemDiscoveredRemotePacket>,
    },
    RemoteFunctions: {}
}

export type Module = typeof(EncyclopediaNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function EncyclopediaNetworkClient.GetDiscoveredItems(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Encyclopedia")

    return Channel:PromiseInvokeServer("GetDiscoveredItems")
end

function EncyclopediaNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceShared = self._ServiceBag:GetService(require("NetworkServiceShared"))

    self.RemoteEvents = {
        ItemDiscovered = Signal.new(),
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function EncyclopediaNetworkClient.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Encyclopedia")

    Channel:Connect("ItemDiscovered", function(packet: EncyclopediaTypesShared.ItemDiscoveredRemotePacket)
        self.RemoteEvents.ItemDiscovered:Fire(packet)
    end)
end

return EncyclopediaNetworkClient :: Module
