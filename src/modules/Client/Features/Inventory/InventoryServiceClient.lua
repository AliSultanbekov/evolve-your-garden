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
local InventoryConfigClient = require("InventoryConfigClient")
local ReactiveItemTypes = require("ReactiveItemTypes")
local ValueObject = require("ValueObject")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _InventoryNetworkClient: typeof(require("InventoryNetworkClient")),
    _Items: InventoryTypesClient.Items,
    _FilteredItems: InventoryTypesClient.FilteredItems,
    _SelectedItem: ValueObject.ValueObject<ReactiveItemTypes.ReactiveItem?>
}

export type Module = typeof(InventoryServiceClient) & ModuleData

-- [ Private Functions ] --
function InventoryServiceClient._SetupFilteredItems(self: Module)
    for tabName, _ in InventoryConfigClient.TabsConfig do
        self._FilteredItems[tabName] = ObservableMap.new()
    end
end

function InventoryServiceClient._ProcessItems(self: Module, items: { [any]: ItemTypes.Item })
    for _, item in items do
        local ReactiveItem = ReactiveItemUtil:ToReactive(item)
        local TabName = InventoryConfigClient.CategoryToTab[item.Category]

        if not self._FilteredItems[TabName] then
            continue
        end

        self._Items:Set(item.Id, ReactiveItem)
        self._FilteredItems[TabName]:Set(item.Id, ReactiveItem)
    end
end

-- [ Public Functions ] --
function InventoryServiceClient.UseAction(self: Module, action: string, params: { [string]: any }?)
    if not self._SelectedItem.Value then
        return 
    end
    
    self._InventoryNetworkClient:UseAction({
        Action = action,
        ItemId = self._SelectedItem.Value.Id,
        Params = params
    })
end

function InventoryServiceClient.SelectItem(self: Module, item: ReactiveItemTypes.ReactiveItem?)
    self._SelectedItem.Value = item
end

function InventoryServiceClient.GetSelectedItem(self: Module)
    return self._SelectedItem.Value
end

function InventoryServiceClient.ObserveSelectedItem(self: Module)
    return self._SelectedItem:Observe()
end

function InventoryServiceClient.GetItems(self: Module, tabFilter: string?)
    if tabFilter then
        return self._FilteredItems[tabFilter]
    else
        return self._Items
    end
end

function InventoryServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._InventoryNetworkClient = self._ServiceBag:GetService(require("InventoryNetworkClient"))
    self._Items = ObservableMap.new()
    self._FilteredItems = {}
    self._SelectedItem = ValueObject.new(nil)

    self:_SetupFilteredItems()
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

            local TabName = InventoryConfigClient.CategoryToTab[item.Category]

            self._FilteredItems[TabName]:Remove(item.Id)
        end
    end)
end

return InventoryServiceClient :: Module