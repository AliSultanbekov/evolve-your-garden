--[=[
    @class StatsServiceClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local StatsConfig = require("StatsConfig")
local ValueObject = require("ValueObject")
local StatsTypesShared = require("StatsTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local StatsServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _StatsNetworkClient: typeof(require("StatsNetworkClient")),
    _Stats: { [string]: ValueObject.ValueObject<number> }
}

export type Module = typeof(StatsServiceClient) & ModuleData

-- [ Private Functions ] --
function StatsServiceClient._SetupStats(self: Module) 
    local Stats = {}

    for _, stat in StatsConfig.Stats do
        Stats[stat] = ValueObject.new(0)
    end

    return Stats
end

-- [ Public Functions ] --
function StatsServiceClient.ObserveStat(self: Module, stat: string)
    return self._Stats[stat]:Observe()
end

function StatsServiceClient.UpdateStat(self: Module, stat: string, value: number)
    local ReactiveStat = self._Stats[stat]

    if not ReactiveStat then
        return
    end

    ReactiveStat.Value = value
end

function StatsServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._StatsNetworkClient = self._ServiceBag:GetService(require("StatsNetworkClient"))
    self._Stats = self:_SetupStats()
end

function StatsServiceClient.Start(self: Module)
    self._StatsNetworkClient:GetStats():Then(function(packet: StatsTypesShared.GetStatsRemotePacket)
        for stat, number in packet.Stats do
            self:UpdateStat(stat, number)
        end
    end)

    self._StatsNetworkClient.RemoteEvents.StatUpdated:Connect(function(packet: StatsTypesShared.StatUpdatedRemotePacket)
        self:UpdateStat(packet.Stat, packet.Value)
    end)
end

return StatsServiceClient :: Module