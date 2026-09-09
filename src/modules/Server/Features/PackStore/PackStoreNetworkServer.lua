--[=[
    @class PackStoreNetworkServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local PackStoreTypesShared = require("PackStoreTypesShared")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PackStoreNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {
        BuyPack: Signal.Signal<Player, PackStoreTypesShared.BuyPackRemotePacket>
    },
    RemoteFunctions: {
        GetCurrentSale: (player: Player) -> PackStoreTypesShared.GetCurrentSaleRemotePacket
    }
}

export type Module = typeof(PackStoreNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --#
function PackStoreNetworkServer.PackBought(self: Module, player: Player, packet: PackStoreTypesShared.PackBoughtRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("PackStore")

    Channel:FireClient("PackBought", player, packet)
end

function PackStoreNetworkServer.Refreshed(self: Module, player: Player, packet: PackStoreTypesShared.RefreshedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("PackStore")

    Channel:FireClient("Refreshed", player, packet)
end

function PackStoreNetworkServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceShared = self._ServiceBag:GetService(require("NetworkServiceShared"))

    self.RemoteEvents = {
        BuyPack = Signal.new()
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function PackStoreNetworkServer.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("PackStore")

    Channel:DeclareEvent("BuyPack")
    Channel:DeclareMethod("GetCurrentSale")

    Channel:DeclareEvent("Refreshed")
    Channel:DeclareEvent("PackBought")

    -- Remoting passes client payloads through verbatim — validate shape here
    -- so service handlers can assume well-formed packets.
    Channel:Connect("BuyPack", function(player: Player, packet: PackStoreTypesShared.BuyPackRemotePacket)
        if typeof(packet) ~= "table" or typeof(packet.PackId) ~= "string" then
            return
        end

        self.RemoteEvents.BuyPack:Fire(player, packet)
    end)

    Channel:Bind("GetCurrentSale", function(player: Player)
        return self.RemoteFunctions.GetCurrentSale(player)
    end)
end

return PackStoreNetworkServer :: Module