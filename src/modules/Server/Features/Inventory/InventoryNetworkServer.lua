--[=[
    @class InventoryNetworkServer
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local InventoryTypesShared = require("InventoryTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {},
    RemoteFunctions: {}
}

export type Module = typeof(InventoryNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function InventoryNetworkServer.ItemsUpdated(self: Module, player: Player, packet: InventoryTypesShared.ItemsUpdatedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Inventory")

    Channel:FireClient("ItemUpdated", player, packet)
end

function InventoryNetworkServer.ItemsAdded(self: Module, player: Player, packet: InventoryTypesShared.ItemsAddedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Inventory")

    Channel:FireClient("ItemUpdated", player, packet)
end

function InventoryNetworkServer.ItemsRemoved(self: Module, player: Player, packet: InventoryTypesShared.ItemsRemovedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Inventory")

    Channel:FireClient("ItemUpdated", player, packet)
end

function InventoryNetworkServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
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

function InventoryNetworkServer.Start(self: Module)

end

return InventoryNetworkServer :: Module