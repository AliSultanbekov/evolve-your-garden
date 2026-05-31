--[=[
    @class WeatherServiceClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ValueObject = require("ValueObject")
local WeatherTypesShared = require("WeatherTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WeatherServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _WeatherNetworkClient: typeof(require("WeatherNetworkClient")),
    _CurrentWeather: ValueObject.ValueObject<WeatherTypesShared.Weather>,
}

export type Module = typeof(WeatherServiceClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function WeatherServiceClient.ObserveCurrentWeather(self: Module)
    return self._CurrentWeather:Observe()
end

function WeatherServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._WeatherNetworkClient = self._ServiceBag:GetService(require("WeatherNetworkClient"))
    self._CurrentWeather = ValueObject.new({
        Name = "None",
        Duration = 0,
        StartTime = 0,
    })
end

function WeatherServiceClient.Start(self: Module)
    self._WeatherNetworkClient:GetCurrentWeather():Then(function(packet: WeatherTypesShared.GetCurrentWeatherRemotePacket)
        self._CurrentWeather.Value = packet.Weather
    end)

    self._WeatherNetworkClient.RemoteEvents.WeatherSelected:Connect(function(packet: WeatherTypesShared.WeatherSelectedRemotePacket)
        self._CurrentWeather.Value = packet.Weather
    end)
end

return WeatherServiceClient :: Module