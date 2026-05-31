
--[=[
    @class TimeWorldClient
]=]

-- [ Roblox Services ] --
local Lighting = game:GetService("Lighting")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local TimeWorldClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _TimeServiceClient: typeof(require("TimeServiceClient"))
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
end

function TimeWorldClient.Start(self: Module)
    self._TimeServiceClient:ObserveTime():Subscribe(function(time: number)
        local Hour, Minute, Second = self._TimeServiceClient:ConvertTimeToHMS(time)

        Lighting.TimeOfDay = string.format("%d:%d:%d", Hour, Minute, Second)
    end)
end

return TimeWorldClient :: Module