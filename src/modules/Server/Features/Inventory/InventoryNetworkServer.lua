--[=[
    @class InventoryNetworkServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local InventoryTypesShared = require("InventoryTypesShared")
local Signal = require("Signal")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryNetworkServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {
        UseAction: Signal.Signal<Player, InventoryTypesShared.UseActionRemotePacket>
    },
    RemoteFunctions: {
        GetItems: (player: Player) -> InventoryTypesShared.GetItemsRemotePacket
    }
}

export type Module = typeof(InventoryNetworkServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function InventoryNetworkServer.ItemsUpdated(self: Module, player: Player, packet: InventoryTypesShared.ItemsUpdatedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Inventory")

    Channel:FireClient("ItemsUpdated", player, packet)
end

function InventoryNetworkServer.ItemsAdded(self: Module, player: Player, packet: InventoryTypesShared.ItemsAddedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Inventory")

    Channel:FireClient("ItemsAdded", player, packet)
end

function InventoryNetworkServer.ItemsRemoved(self: Module, player: Player, packet: InventoryTypesShared.ItemsRemovedRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Inventory")

    Channel:FireClient("ItemsRemoved", player, packet)
end

function InventoryNetworkServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceShared = self._ServiceBag:GetService(require("NetworkServiceShared"))

    self.RemoteEvents = {
        UseAction = Signal.new()
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function InventoryNetworkServer.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Inventory")

    Channel:DeclareEvent("UseAction")
    Channel:DeclareMethod("GetItems")

    Channel:DeclareEvent("ItemsUpdated")
    Channel:DeclareEvent("ItemsAdded")
    Channel:DeclareEvent("ItemsRemoved")

    Channel:Bind("GetItems", function(player: Player)
        return self.RemoteFunctions.GetItems(player)
    end)

    Channel:Connect("UseAction", function(player: Player, packet: InventoryTypesShared.UseActionRemotePacket)  
        self.RemoteEvents.UseAction:Fire(player, packet)
    end)
end

return InventoryNetworkServer :: Module