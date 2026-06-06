--[=[
    @class PackStoreNetworkClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")
local PackStoreTypesShared = require("PackStoreTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PackStoreNetworkClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {
        PackBought: Signal.Signal<PackStoreTypesShared.PackBoughtRemotePacket>,
        Refreshed: Signal.Signal<PackStoreTypesShared.RefreshedRemotePacket>
    },
    RemoteFunctions: {}
}

export type Module = typeof(PackStoreNetworkClient) & ModuleData

-- [ Private Functions ] --
function PackStoreNetworkClient.BuyPack(self: Module, packet: PackStoreTypesShared.BuyPackRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("PackStore")

    Channel:FireServer("BuyPack", packet)
end

function PackStoreNetworkClient.GetCurrentSale(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("PackStore")

    return Channel:PromiseInvokeServer("GetCurrentSale")
end

-- [ Public Functions ] --
function PackStoreNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceShared = self._ServiceBag:GetService(require("NetworkServiceShared"))

    self.RemoteEvents = {
        PackBought = Signal.new(),
        Refreshed = Signal.new()
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function PackStoreNetworkClient.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("PackStore")

    Channel:Connect("PackBought", function(packet: PackStoreTypesShared.PackBoughtRemotePacket)
        self.RemoteEvents.PackBought:Fire(packet)
    end)

    Channel:Connect("Refreshed", function(packet: PackStoreTypesShared.RefreshedRemotePacket)
        self.RemoteEvents.Refreshed:Fire(packet)
    end)
end

return PackStoreNetworkClient :: Module