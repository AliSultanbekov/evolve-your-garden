--[=[
    @class MerchantNetworkServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local MerchantTypesShared = require("MerchantTypesShared")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local MerchantNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {
        Buy: Signal.Signal<Player, MerchantTypesShared.BuyRemotePacket>,
        Sell: Signal.Signal<Player, MerchantTypesShared.SellRemotePacket>,
    },
    RemoteFunctions: {
        GetBuySlots: (player: Player) -> MerchantTypesShared.GetBuySlotsRemotePacket
    }
}

export type Module = typeof(MerchantNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function MerchantNetworkServer.Bought(self: Module, player: Player, packet: MerchantTypesShared.BoughtRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Merchant")

    Channel:FireClient("Bought", player, packet)
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
        Buy = Signal.new(),
        Sell = Signal.new(),
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function MerchantNetworkServer.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Merchant")

    Channel:DeclareMethod("GetBuySlots")
    Channel:DeclareEvent("Refreshed")
    Channel:DeclareEvent("Bought")
    Channel:DeclareEvent("Buy")
    Channel:DeclareEvent("Sell")

    Channel:Bind("GetBuySlots", function(player: Player)
        return self.RemoteFunctions.GetBuySlots(player)
    end)

    -- Remoting passes client payloads through verbatim — validate shape here
    -- so service handlers can assume well-formed packets.
    Channel:Connect("Buy", function(player: Player, packet: MerchantTypesShared.BuyRemotePacket)
        if typeof(packet) ~= "table" or typeof(packet.SlotId) ~= "string" then
            return
        end

        self.RemoteEvents.Buy:Fire(player, packet)
    end)

    Channel:Connect("Sell", function(player: Player, packet: MerchantTypesShared.SellRemotePacket)
        if typeof(packet) ~= "table" or typeof(packet.ItemId) ~= "string" or typeof(packet.Amount) ~= "number" then
            return
        end

        self.RemoteEvents.Sell:Fire(player, packet)
    end)
end

return MerchantNetworkServer :: Module