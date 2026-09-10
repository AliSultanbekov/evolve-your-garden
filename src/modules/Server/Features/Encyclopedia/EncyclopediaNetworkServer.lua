--[=[
    @class EncyclopediaNetworkServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local EncyclopediaTypesShared = require("EncyclopediaTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local EncyclopediaNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {},
    RemoteFunctions: {
        GetDiscoveredItems: (player: Player) -> EncyclopediaTypesShared.GetDiscoveredItemsRemotePacket
    }
}

export type Module = typeof(EncyclopediaNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function EncyclopediaNetworkServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
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

function EncyclopediaNetworkServer.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Encyclopedia")

    Channel:DeclareEvent("ItemDiscovered")
    Channel:DeclareMethod("GetDiscoveredItems")

    Channel:Bind("GetDiscoveredItems", function(player: Player)
        return self.RemoteFunctions.GetDiscoveredItems(player)
    end)
end

return EncyclopediaNetworkServer :: Module
