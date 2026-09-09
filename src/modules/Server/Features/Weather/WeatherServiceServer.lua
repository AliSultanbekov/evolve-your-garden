--[=[
    @class WeatherServiceServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local WeatherTypesShared = require("WeatherTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WeatherServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _WeatherNetworkServer: typeof(require("WeatherNetworkServer")),
    _JavaBackendServiceServer: typeof(require("JavaBackendServiceServer")),
    _CurrentWeather: WeatherTypesShared.Weather,
}

export type Module = typeof(WeatherServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function WeatherServiceServer.SelectWeather(self: Module, weather: WeatherTypesShared.Weather)
    self._CurrentWeather = weather
    
    self._WeatherNetworkServer:WeatherSelected({
        Weather = weather
    })
end

function WeatherServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._WeatherNetworkServer = self._ServiceBag:GetService(require("WeatherNetworkServer"))
    self._JavaBackendServiceServer = self._ServiceBag:GetService(require("JavaBackendServiceServer"))
    self._CurrentWeather = {
        Name = "None",
        Duration = 0,
        StartTime = 0,
    }
end

function WeatherServiceServer.Start(self: Module)
    self._WeatherNetworkServer.RemoteFunctions["GetCurrentWeather"] = function()
        return { Weather = self._CurrentWeather }
    end
    
    task.spawn(function()
        self:SelectWeather(self._JavaBackendServiceServer:GetWeather())

        self._JavaBackendServiceServer:SubsribeToWeather(function(packet)
            self:SelectWeather(packet)
        end)
    end)
end

return WeatherServiceServer :: Module