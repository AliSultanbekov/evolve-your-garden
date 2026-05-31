--[=[
    @class WeatherNetworkClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local WeatherTypesShared = require("WeatherTypesShared")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local WeatherNetworkClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {
        WeatherSelected: Signal.Signal<WeatherTypesShared.WeatherSelectedRemotePacket>
    },
    RemoteFunctions: {}
}

export type Module = typeof(WeatherNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function WeatherNetworkClient.GetCurrentWeather(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Weather")

    return Channel:PromiseInvokeServer("GetCurrentWeather")
end

function WeatherNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceShared = self._ServiceBag:GetService(require("NetworkServiceShared"))

    self.RemoteEvents = {
        WeatherSelected = Signal.new()
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function WeatherNetworkClient.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Weather")

    Channel:Connect("WeatherSelected", function(packet: WeatherTypesShared.WeatherSelectedRemotePacket)
        self.RemoteEvents.WeatherSelected:Fire(packet)
    end)
end

return WeatherNetworkClient :: Module