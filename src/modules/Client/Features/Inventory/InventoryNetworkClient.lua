--[=[
    @class InventoryNetworkClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local Signal = require("Signal")
local InventoryTypesShared = require("InventoryTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryNetworkClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _NetworkServiceShared: typeof(require("NetworkServiceShared")),

    RemoteEvents: {
        ItemsUpdated: Signal.Signal<InventoryTypesShared.ItemsUpdatedRemotePacket>,
        ItemsAdded: Signal.Signal<InventoryTypesShared.ItemsAddedRemotePacket>,
        ItemsRemoved: Signal.Signal<InventoryTypesShared.ItemsRemovedRemotePacket>
    },
    RemoteFunctions: {}
}

export type Module = typeof(InventoryNetworkClient) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function InventoryNetworkClient.UseAction(self: Module, packet: InventoryTypesShared.UseActionRemotePacket)
    local Channel = self._NetworkServiceShared:GetChannel("Inventory")

    Channel:FireServer("UseAction", packet)
end

function InventoryNetworkClient.GetItems(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Inventory")

    return Channel:PromiseInvokeServer("GetItems")
end

function InventoryNetworkClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._NetworkServiceShared = self._ServiceBag:GetService(require("NetworkServiceShared"))

    self.RemoteEvents = {
        ItemsUpdated = Signal.new(),
        ItemsAdded = Signal.new(),
        ItemsRemoved = Signal.new()
    } :: any

    self.RemoteFunctions = {

    } :: any
end

function InventoryNetworkClient.Start(self: Module)
    local Channel = self._NetworkServiceShared:GetChannel("Inventory")

    Channel:Connect("ItemsUpdated", function(packet: InventoryTypesShared.ItemsUpdatedRemotePacket)
        self.RemoteEvents.ItemsUpdated:Fire(packet) 
    end)

    Channel:Connect("ItemsAdded", function(packet: InventoryTypesShared.ItemsAddedRemotePacket)
        self.RemoteEvents.ItemsAdded:Fire(packet) 
    end)

    Channel:Connect("ItemsRemoved", function(packet: InventoryTypesShared.ItemsRemovedRemotePacket)
        self.RemoteEvents.ItemsRemoved:Fire(packet) 
    end)
end

return InventoryNetworkClient :: Module