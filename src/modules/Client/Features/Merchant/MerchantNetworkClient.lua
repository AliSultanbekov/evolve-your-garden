--[=[
    @class MerchantNetworkClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local MerchantNetworkClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {},
    RemoteFunctions: {}
}

export type Module = typeof(MerchantNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function MerchantNetworkClient.GetSlots(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Merchant")

    return Channel:PromiseInvokeServer("GetBuySlots")
end

function MerchantNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
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

function MerchantNetworkClient.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Merchant")
end

return MerchantNetworkClient :: Module