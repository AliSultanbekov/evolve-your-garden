--[=[
    @class StatsService
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local RxPlayerUtils = require("RxPlayerUtils")
local Brio = require("Brio")
local Maid = require("Maid")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local StatsService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataServiceServer: typeof(require("DataServiceServer")),
    Signals: {
        StatUpdated: Signal.Signal<Player, string, number, number>
    }
}

export type Module = typeof(StatsService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function StatsService.GetStat(self: Module, player: Player, stat: string): number
    local PlayerData = self._DataServiceServer:GetData(player)
    local StatsData = PlayerData.Stats

    local StatData = StatsData[stat]

    if not StatData then
        error(`[StatsService] Stat "{stat}" not found for player {player.Name}`) 
    end

    return StatData
end

function StatsService.UpdateStat(self: Module, player: Player, stat: string, value: number)
    local PlayerData = self._DataServiceServer:GetData(player)
    local StatsData = PlayerData.Stats

    local StatData = StatsData[stat]

    if not StatData then
        warn(`[StatsService] Stat "{stat}" not found for player {player.Name}`)
        return
    end

    local OldStatData = StatData

    StatsData[stat] = value

    self.Signals.StatUpdated:Fire(player, stat, value, OldStatData)
end

function StatsService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._DataServiceServer = self._ServiceBag:GetService(require("DataServiceServer"))
    self.Signals = {
        StatUpdated = Signal.new()
    } :: any
end

function StatsService.Start(self: Module)
    RxPlayerUtils.observePlayersBrio():Subscribe(function(brio: Brio.Brio<Player>)
        local MaidObject: Maid.Maid, Player: Player = brio:ToMaidAndValue()

        MaidObject:Add(self._DataServiceServer:OnDataReady(Player, function(data)
            local SessionStart = os.time()
            local Flushed = 0
            local Running = true

            local function FlushPlaytime()
                local Elapsed = os.time() - SessionStart
                local StalePlayTime = data.Stats.PlayTime or 0
                local NewPlayTime = StalePlayTime + (Elapsed - Flushed)

                data.Stats.PlayTime = NewPlayTime
                Flushed = Elapsed

                self.Signals.StatUpdated:Fire(Player, "PlayTime", NewPlayTime, StalePlayTime)
            end

            task.spawn(function()
                while Running do
                    task.wait(60)

                    if Running then
                        FlushPlaytime()
                    end
                end
            end)

            return function()
                Running = false
                FlushPlaytime()
            end
        end))
    end)
end

return StatsService :: Module