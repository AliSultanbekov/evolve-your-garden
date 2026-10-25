--[=[
    @class ToolsNetworkServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ToolsTypesShared = require("ToolsTypesShared")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolsNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {
        ActivateTool: Signal.Signal<Player, ToolsTypesShared.ActivateToolRemotePacket>,
    },
    RemoteFunctions: {}
}

export type Module = typeof(ToolsNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolsNetworkServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceShared = self._ServiceBag:GetService(require("NetworkServiceShared"))

    self.RemoteEvents = {
        ActivateTool = Signal.new(),
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function ToolsNetworkServer.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Tools")

    Channel:DeclareEvent("ActivateTool")

    Channel:Connect("ActivateTool", function(player: Player, packet: ToolsTypesShared.ActivateToolRemotePacket)
        if typeof(packet) ~= "table" then
            return
        end

        if packet.Params ~= nil and typeof(packet.Params) ~= "table" then
            return
        end

        self.RemoteEvents.ActivateTool:Fire(player, packet)
    end)
end

return ToolsNetworkServer :: Module
