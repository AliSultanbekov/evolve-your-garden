--[=[
    @class ToolsNetworkClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ToolsTypesShared = require("ToolsTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolsNetworkClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {},
    RemoteFunctions: {}
}

export type Module = typeof(ToolsNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolsNetworkClient.ActivateTool(self: Module, packet: ToolsTypesShared.ActivateToolRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Tools")

    Channel:FireServer("ActivateTool", packet)
end

function ToolsNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
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

function ToolsNetworkClient.Start(self: Module)

end

return ToolsNetworkClient :: Module
