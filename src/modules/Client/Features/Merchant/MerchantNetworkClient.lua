--[=[
    @class MerchantNetworkClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")
local MerchantTypesShared = require("MerchantTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local MerchantNetworkClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {
        Refreshed: Signal.Signal<MerchantTypesShared.RefreshedRemotePacket>,
        Bought: Signal.Signal<MerchantTypesShared.BoughtRemotePacket>,
    },
    RemoteFunctions: {}
}

export type Module = typeof(MerchantNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function MerchantNetworkClient.GetSlots(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Merchant")

    return Channel:PromiseInvokeServer("GetBuySlots")
end

function MerchantNetworkClient.Buy(self: Module, packet: MerchantTypesShared.BuyRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Merchant")

    Channel:FireServer("Buy", packet)
end

function MerchantNetworkClient.Sell(self: Module, packet: MerchantTypesShared.SellRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Merchant")

    Channel:FireServer("Sell", packet)
end

function MerchantNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceShared = self._ServiceBag:GetService(require("NetworkServiceShared"))

    self.RemoteEvents = {
        Refreshed = Signal.new(),
        Bought = Signal.new(),
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function MerchantNetworkClient.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Merchant")

    Channel:Connect("Refreshed", function(packet: MerchantTypesShared.RefreshedRemotePacket)
        self.RemoteEvents.Refreshed:Fire(packet)
    end)

    Channel:Connect("Bought", function(packet: MerchantTypesShared.BoughtRemotePacket)
        self.RemoteEvents.Bought:Fire(packet)
    end)
end

return MerchantNetworkClient :: Module
