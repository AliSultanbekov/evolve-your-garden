--[=[
    @class ToolbarNetworkClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ToolbarTypesShared = require("ToolbarTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolbarNetworkClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {},
    RemoteFunctions: {}
}

export type Module = typeof(ToolbarNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ToolbarNetworkClient.GetSlots(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Toolbar")

    return Channel:PromiseInvokeServer("GetSlots")
end

function ToolbarNetworkClient.BindSlots(self: Module, packet: ToolbarTypesShared.BindSlotsRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Toolbar")

    Channel:FireServer("BindSlots", packet)
end

function ToolbarNetworkClient.EquipSlot(self: Module, packet: ToolbarTypesShared.EquipSlotRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Toolbar")

    Channel:FireServer("EquipSlot", packet)
end

function ToolbarNetworkClient.UnbindSlots(self: Module, packet: ToolbarTypesShared.UnbindSlotsRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Toolbar")

    Channel:FireServer("UnbindSlots", packet)
end

function ToolbarNetworkClient.UnequipSlot(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Toolbar")

    Channel:FireServer("UnequipSlot")
end

function ToolbarNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
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

function ToolbarNetworkClient.Start(self: Module)

end

return ToolbarNetworkClient :: Module
