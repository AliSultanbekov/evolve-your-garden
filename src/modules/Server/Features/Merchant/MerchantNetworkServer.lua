--[=[
    @class MerchantNetworkServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local MerchantTypesShared = require("MerchantTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local MerchantNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {},
    RemoteFunctions: {
        GetBuySlots: (player: Player) -> MerchantTypesShared.GetBuySlotsRemotePacket
    }
}

export type Module = typeof(MerchantNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function MerchantNetworkServer.Bought(self: Module, player: Player, packet: MerchantTypesShared.BoughtRemotePacket)
    
end

function MerchantNetworkServer.Refreshed(self: Module, player: Player, packet: MerchantTypesShared.RefreshedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Merchant")

    Channel:FireClient("Refreshed", player, packet)
end

function MerchantNetworkServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
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

function MerchantNetworkServer.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Merchant")

    Channel:DeclareMethod("GetBuySlots")
    Channel:DeclareEvent("Refreshed")
    Channel:DeclareEvent("Bought")

    Channel:Bind("GetBuySlots", function(player: Player)
        return self.RemoteFunctions.GetBuySlots(player)
    end)
end

return MerchantNetworkServer :: Module