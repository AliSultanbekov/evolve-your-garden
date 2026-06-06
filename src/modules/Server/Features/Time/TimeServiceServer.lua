--[=[
    @class TimeServiceServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Time = require("Time")
local TimeTypesShared = require("TimeTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local TimeServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
}

export type Module = typeof(TimeServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function TimeServiceServer.GetPhase(self: Module): TimeTypesShared.Phase
    local Hour = self:GetHMS()

    if Hour >= 6 and Hour < 8 then
        return "Sunrise"
    elseif Hour >= 8 and Hour < 18 then
        return "Day"
    elseif Hour >= 18 and Hour < 20 then
        return "Sunset"
    else
        return "Night"
    end
end

function TimeServiceServer.GetHMS(self: Module): (number, number, number)
    local GameTime = self:GetTime()
    local Hour = Time.getHour(GameTime)
    local Minute = Time.getMinute(GameTime)
    local Second = Time.getSecond(GameTime)

    return Hour, Minute, Second
end

function TimeServiceServer.GetTime(self: Module): number
    return math.floor(workspace:GetServerTimeNow() * 60)
end

function TimeServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
end

function TimeServiceServer.Start(self: Module)
    
end

return TimeServiceServer :: Module