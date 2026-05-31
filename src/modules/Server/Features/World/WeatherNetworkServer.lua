--[=[
    @class WeatherNetworkServer
]=]

-- [ Roblox Services ] --
local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")

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

function WeatherNetworkServer.SubsribeToWeather(self: Module, cb: (message: any) -> ())
    MessagingService:SubscribeAsync("Weather", cb)
end

function WeatherNetworkServer.GetWeather(self: Module)
    local Response = HttpService:RequestAsync({
        Url = "https://evolveyourgardenbackend-production.up.railway.app/weather",
        Method = "GET",
    })

    if Response.Success then
        local Packet: WeatherTypesShared.WeatherMessagePacket = HttpService:JSONDecode(Response.Body)

        return Packet
    else
        return {
            Name = "None",
            Duration = 0,
            StartTime = 0,
        }
    end
end

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
end

return WeatherNetworkServer :: Module