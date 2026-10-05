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

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local StatsServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Stats: { [string]: ValueObject.ValueObject<number> }
}

export type Module = typeof(StatsServiceClient) & ModuleData

-- [ Private Functions ] --
function StatsServiceClient._SetupStats(self: Module) 
    local Stats = {}

    for _, stat in StatsConfig.Stats do
        Stats[stat] = ValueObject.new()
    end

    return Stats
end

-- [ Public Functions ] --
function StatsServiceClient.ObserveStat(self: Module, stat: string)
    return self._Stats[stat]:Observe()
end

function StatsServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Stats = self:_SetupStats()
end

function StatsServiceClient.Start(self: Module)
    
end

return StatsServiceClient :: Module