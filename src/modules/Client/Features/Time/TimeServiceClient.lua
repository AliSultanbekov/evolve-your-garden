--[=[
    @class TimeServiceClient
]=]

-- [ Roblox Services ] --
local RunService = game:GetService("RunService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ValueObject = require("ValueObject")
local Time = require("Time")
local TimeTypesShared = require("TimeTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local TimeServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Time: ValueObject.ValueObject<number>,
    _Phase: ValueObject.ValueObject<TimeTypesShared.Phase>
}

export type Module = typeof(TimeServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function TimeServiceClient.GetHMS(self: Module)
    return self:ConvertTimeToHMS(self._Time.Value)
end

function TimeServiceClient.ConvertTimeToHMS(self: Module, time: number): (number, number, number)
    local Hour = Time.getHour(time)
    local Minute = Time.getMinute(time)
    local Second = Time.getSecond(time)

    return Hour, Minute, Second
end

function TimeServiceClient.ObserveTime(self: Module)
    return self._Time:Observe()
end

function TimeServiceClient.SetTime(self: Module, time: number)
    self._Time.Value = time
end

function TimeServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Time = ValueObject.new(0)
    self._Phase = ValueObject.new("Day" :: any)
end

function TimeServiceClient.Start(self: Module)
    RunService.Heartbeat:Connect(function(dt: number)
        self._Time.Value = math.floor(workspace:GetServerTimeNow() * 60)

        local Hour = self:GetHMS()

        if Hour >= 6 and Hour < 8 then
            self._Phase.Value = "Sunrise"
        elseif Hour >= 8 and Hour < 18 then
            self._Phase.Value = "Day"
        elseif Hour >= 18 and Hour < 20 then
            self._Phase.Value = "Sunset"
        else
            self._Phase.Value = "Night"
        end
    end)
end

return TimeServiceClient :: Module