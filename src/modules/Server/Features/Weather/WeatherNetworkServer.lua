--[=[
    @class WeatherNetworkServer
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
local WeatherNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {},
    RemoteFunctions: {
        ["GetCurrentWeather"]: () -> WeatherTypesShared.GetCurrentWeatherRemotePacket
    }
}

export type Module = typeof(WeatherNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function WeatherNetworkServer.WeatherSelected(self: Module, packet: WeatherTypesShared.WeatherSelectedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Weather")

    Channel:FireAllClients("WeatherSelected", packet)
end

function WeatherNetworkServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceShared = self._ServiceBag:GetService(require("NetworkServiceShared"))

    self.RemoteEvents = {

    } :: any

    self.RemoteFunctions = {

    } :: any
end

function WeatherNetworkServer.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Weather")

    Channel:DeclareEvent("WeatherSelected")
    Channel:DeclareMethod("GetCurrentWeather")

    Channel:Bind("GetCurrentWeather", function(player: Player, packet: WeatherTypesShared.GetCurrentWeatherRemotePacket)
        return self.RemoteFunctions.GetCurrentWeather()
    end)
end

return WeatherNetworkServer :: Module