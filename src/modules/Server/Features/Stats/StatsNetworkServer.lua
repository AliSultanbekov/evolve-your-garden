--[=[
    @class StatsNetworkServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local StatsTypesShared = require("StatsTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local StatsNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {},
    RemoteFunctions: {
        GetStats: (player: Player) -> StatsTypesShared.GetStatsRemotePacket
    }
}

export type Module = typeof(StatsNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function StatsNetworkServer.StatUpdated(self: Module, player: Player, packet: StatsTypesShared.StatUpdatedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Stats")

    Channel:FireClient("StatUpdated", player, packet)
end

function StatsNetworkServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
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

function StatsNetworkServer.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Stats")

    Channel:DeclareMethod("GetStats")
    Channel:DeclareEvent("StatUpdated")

    Channel:Bind("GetStats", function(player: Player)
        return self.RemoteFunctions.GetStats(player)
    end)
end

return StatsNetworkServer :: Module
