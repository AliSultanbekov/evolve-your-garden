
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
function JavaBackendServiceServer._DecodeMessage(self: Module, message: any): any?
    local Ok, Packet = pcall(function()
        return HttpService:JSONDecode(message.Data)
    end)

    if not Ok or typeof(Packet) ~= "table" then
        warn("[JavaBackendServiceServer] Ignoring malformed message payload")

        return nil
    end

    return Packet
end

function JavaBackendServiceServer._RequestAsync(self: Module, path: string, method: string)
    local Ok, Response = pcall(function()
        return HttpService:RequestAsync({
            Url = self._Domain .. "/" .. path,
            Method = method,
            Headers = {
                ["x-api-key"] = self._Secret
            }
        })
    end)

    if not Ok then
        warn(`[JavaBackendServiceServer] Request '{path}' failed:`, Response)

        return { Success = false, StatusCode = 0, Body = "" }
    end

    return Response
end

-- [ Public Functions ] --
function JavaBackendServiceServer.SubsribeToPackStoreRefreshed(self: Module, cb: (packet: JavaBackendTypesShared.PackStoreRefreshedPacket) -> ())
    return MessagingService:SubscribeAsync("PackStoreRefreshed", function(message: any)
        local Packet = self:_DecodeMessage(message)

        if Packet then
            cb(Packet)
        end
    end)
end

function JavaBackendServiceServer.SubsribeToWeather(self: Module, cb: (packet: JavaBackendTypesShared.WeatherPacket) -> ())
    return MessagingService:SubscribeAsync("Weather", function(message: any)
        local Packet = self:_DecodeMessage(message)

        if Packet then
            cb(Packet)
        end
    end)
end

function JavaBackendServiceServer.GetPackStoreCurrentSale(self: Module)
    local Response = self:_RequestAsync("packstore/current-sale", "GET")

    local Ok, Packet = pcall(function(): JavaBackendTypesShared.PackStoreRefreshedPacket
        return HttpService:JSONDecode(Response.Body)
    end)

    if Response.Success and Ok then
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

    local Ok, Packet = pcall(function(): JavaBackendTypesShared.WeatherPacket
        return HttpService:JSONDecode(Response.Body)
    end)

    if Response.Success and Ok then
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

    local Ok, Secret = pcall(function()
        return HttpService:GetSecret("BACKEND_API_KEY")
    end)

    if Ok then
        self._Secret = Secret
    else
        warn("[JavaBackendServiceServer] BACKEND_API_KEY secret unavailable — backend requests will fail")
    end
end

function JavaBackendServiceServer.Start(self: Module)

end

return JavaBackendServiceServer :: Module