
--[=[
    @class TimeWorldClient
]=]

-- [ Roblox Services ] --
local Lighting = game:GetService("Lighting")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local TimeWorldClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _TimeServiceClient: typeof(require("TimeServiceClient")),
    _Maid: Maid.Maid
}

export type Module = typeof(TimeWorldClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function TimeWorldClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._TimeServiceClient = self._ServiceBag:GetService(require("TimeServiceClient"))
    self._Maid = Maid.new()
end

function TimeWorldClient.Start(self: Module)
    -- TimeOfDay expects zero-padded "HH:MM:SS" — "%d" produced "6:5:3".
    -- Also dedupe: no reason to invalidate Lighting when the string hasn't changed.
    local LastTimeOfDay: string? = nil

    self._Maid:Add(self._TimeServiceClient:ObserveTime():Subscribe(function(time: number)
        local Hour, Minute, Second = self._TimeServiceClient:ConvertTimeToHMS(time)
        local TimeOfDay = string.format("%02d:%02d:%02d", Hour, Minute, Second)

        if TimeOfDay ~= LastTimeOfDay then
            LastTimeOfDay = TimeOfDay
            Lighting.TimeOfDay = TimeOfDay
        end
    end))
end

return TimeWorldClient :: Module