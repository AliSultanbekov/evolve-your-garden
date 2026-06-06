
--[=[
    @class JavaBackendServiceServer
]=]

-- [ Roblox Services ] --
local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local JavaBackendTypesShared = require("JavaBackendTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local JavaBackendServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _Domain: string,
    _Secret: Secret,
}

export type Module = typeof(JavaBackendServiceServer) & ModuleData

-- [ Private Functions ] --
function JavaBackendServiceServer._RequestAsync(self: Module, path: string, method: string)
    local Response = HttpService:RequestAsync({
        Url = "https://evolveyourgardenbackend-production.up.railway.app/" .. path,
        Method = method,
        Headers = {
            ["x-api-key"] = self._Secret
        }
    })

    return Response
end

-- [ Public Functions ] --
function JavaBackendServiceServer.SubsribeToPackStoreRefreshed(self: Module, cb: (packet: JavaBackendTypesShared.PackStoreRefreshedPacket) -> ())
    return MessagingService:SubscribeAsync("PackStoreRefreshed", function(message: any)
        local Packet = HttpService:JSONDecode(message.Data)

        cb(Packet)
    end)
end

function JavaBackendServiceServer.SubsribeToWeather(self: Module, cb: (packet: JavaBackendTypesShared.WeatherPacket) -> ())
    return MessagingService:SubscribeAsync("Weather", function(message: any)
        local Packet = HttpService:JSONDecode(message.Data)

        cb(Packet)
    end)
end

function JavaBackendServiceServer.GetPackStoreCurrentSale(self: Module)
    local Response = self:_RequestAsync("packstore/current-sale", "GET")

    if Response.Success then
        local Packet: JavaBackendTypesShared.PackStoreRefreshedPacket = HttpService:JSONDecode(Response.Body)

        return Packet
    else
        return {
            SaleId = "",
            Packs = {},
            StartTime = 0,
        }
    end
end

function JavaBackendServiceServer.GetWeather(self: Module)
    local Response = self:_RequestAsync("weather", "GET")

    if Response.Success then
        local Packet: JavaBackendTypesShared.WeatherPacket = HttpService:JSONDecode(Response.Body)

        return Packet
    else
        return {
            Name = "None",
            Duration = 0,
            StartTime = 0,
        }
    end
end

function JavaBackendServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._Domain = "https://evolveyourgardenbackend-production.up.railway.app"
    self._Secret = HttpService:GetSecret("BACKEND_API_KEY")
end

function JavaBackendServiceServer.Start(self: Module)

end

return JavaBackendServiceServer :: Module