
--[=[
    @class WeatherWorldClient
]=]

-- [ Roblox Services ] --
local Lighting = game:GetService("Lighting")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Maid = require("Maid")
local WeatherTypesShared = require("WeatherTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WeatherWorldClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _WeatherServiceClient: typeof(require("WeatherServiceClient")),
    _Weathers: {
        ["None"]: typeof(require(script.Parent.Weathers._None)),
        ["Rainy"]: typeof(require(script.Parent.Weathers._Rainy)),
    },
    _Maid: Maid.Maid,
}

export type Module = typeof(WeatherWorldClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function WeatherWorldClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._WeatherServiceClient = self._ServiceBag:GetService(require("WeatherServiceClient"))
    self._Weathers = {
        ["None"] = require(script.Parent.Weathers._None),
        ["Rainy"] = require(script.Parent.Weathers._Rainy)
    }
    self._Maid = Maid.new()
end

function WeatherWorldClient.Start(self: Module)
    for _, instance in Lighting:GetChildren() do
        instance:Destroy()
    end

    local WeatherMaid = Maid.new()
    self._Maid:Add(WeatherMaid)

    self._Maid:Add(self._WeatherServiceClient:ObserveCurrentWeather():Subscribe(function(weather: WeatherTypesShared.Weather)
        local WeatherComponent = self._Weathers[weather.Name]

        if not WeatherComponent then
            warn(`[WeatherWorldClient] No weather component for "{weather.Name}"`)
            return
        end

        WeatherMaid:DoCleaning()

        WeatherMaid:Add(WeatherComponent({
            Weather = weather
        }))
    end))
end

return WeatherWorldClient :: Module