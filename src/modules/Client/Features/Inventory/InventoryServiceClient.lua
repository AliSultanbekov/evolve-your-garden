--[=[
    @class InventoryServiceClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local InventoryTypesShared = require("InventoryTypesShared")
local ReactiveItemUtil = require("ReactiveItemUtil")
local ObservableMap = require("ObservableMap")
local InventoryTypesClient = require("InventoryTypesClient")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _InventoryNetworkClient: typeof(require("InventoryNetworkClient")),
    _Items: InventoryTypesClient.Items
}

export type Module = typeof(InventoryServiceClient) & ModuleData

-- [ Private Functions ] --
function InventoryServiceClient._ProcessItems(self: Module, items: { [any]: ItemTypes.Item })
    for _, item in items do
        self._Items:Set(item.Id, ReactiveItemUtil:ToReactive(item))
    end
end

function InventoryServiceClient.GetItems(self: Module)
    return self._Items
end

-- [ Public Functions ] --
function InventoryServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._InventoryNetworkClient = self._ServiceBag:GetService(require("InventoryNetworkClient"))
    self._Items = ObservableMap.new()
end

function InventoryServiceClient.Start(self: Module)
    self._InventoryNetworkClient:GetItems():Then(function(packet: InventoryTypesShared.GetItemsRemotePacket)
        self:_ProcessItems(packet.Items)
    end)

    self._InventoryNetworkClient.RemoteEvents.ItemsUpdated:Connect(function(packet: InventoryTypesShared.ItemsUpdatedRemotePacket)
        for _, item in packet.Items do
            local Item = self._Items:Get(item.Id)

            if not Item then
                continue
            end

            ReactiveItemUtil:SyncFromPlain(Item, item)
        end
    end)    

    self._InventoryNetworkClient.RemoteEvents.ItemsAdded:Connect(function(packet: InventoryTypesShared.ItemsAddedRemotePacket)
        self:_ProcessItems(packet.Items)
    end)

    self._InventoryNetworkClient.RemoteEvents.ItemsRemoved:Connect(function(packet: InventoryTypesShared.ItemsRemovedRemotePacket)
        for _, item in packet.Items do
            self._Items:Remove(item.Id)
        end
    end)
end

return InventoryServiceClient :: Module