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
local ItemConfig = require("ItemConfig")
local Signal = require("Signal")
local ValueObject = require("ValueObject")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryServiceClient = {}

-- [ Types ] --
type Signals = {
    ItemAdded: Signal.Signal<ReactiveItemTypes.ReactiveItem>,
    ItemRemoved: Signal.Signal<ItemTypes.ItemId>,
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _InventoryNetworkClient: typeof(require("InventoryNetworkClient")),
    _Items: ReactiveItemTypes.ReactiveItems,
    _TabToItems: InventoryTypesClient.TabToItems,
    _CategoryToItems: InventoryTypesClient.CategoryToItems,
    _SelectedItem: ValueObject.ValueObject<ReactiveItemTypes.ReactiveItem?>,

    Signals: Signals,
}

export type Module = typeof(InventoryServiceClient) & ModuleData

-- [ Private Functions ] --
function InventoryServiceClient._SetupItemIndexes(self: Module)
    for tab, _ in InventoryConfigClient.TabsConfig do
        self._TabToItems[tab] = ObservableMap.new()
    end

    for _, category: ItemTypes.Category in ItemConfig.Categories :: { ItemTypes.Category } do
        self._CategoryToItems[category] = ObservableMap.new()
    end
end

function InventoryServiceClient._AddItems(self: Module, items: { [any]: ItemTypes.Item })
    for _, item in items do
        local ReactiveItem = ReactiveItemUtil:ToReactive(item)
        local Tab = InventoryConfigClient.CategoryToTab[item.Category]

        if not self._TabToItems[Tab] then
            continue
        end

        self._Items:Set(item.Id, ReactiveItem)
        self._TabToItems[Tab]:Set(item.Id, ReactiveItem)
        self._CategoryToItems[item.Category]:Set(item.Id, ReactiveItem)

        self.Signals.ItemAdded:Fire(ReactiveItem)
    end
end

function InventoryServiceClient._RemoveItems(self: Module, itemIds: { ItemTypes.ItemId })
    for _, itemId in itemIds do
        local Item = self._Items:Get(itemId)

        if not Item then
            continue
        end

        local Tab = InventoryConfigClient.CategoryToTab[Item.Category]

        self._Items:Remove(itemId)

        if self._TabToItems[Tab] then
            self._TabToItems[Tab]:Remove(itemId)
        end

        if self._CategoryToItems[Item.Category] then
            self._CategoryToItems[Item.Category]:Remove(itemId)
        end

        -- Selection may never point at an item that left the inventory.
        local SelectedItem = self._SelectedItem.Value

        if SelectedItem and SelectedItem.Id == itemId then
            self._SelectedItem.Value = nil
        end

        self.Signals.ItemRemoved:Fire(itemId)
    end
end

-- [ Public Functions ] --
function InventoryServiceClient.UseItemAction(self: Module, item: ReactiveItemTypes.ReactiveItem, action: string, params: { [string]: any }?)
    self._InventoryNetworkClient:UseAction({
        Action = action,
        ItemId = item.Id,
        Params = params
    })
end

function InventoryServiceClient.GetItemsByCategory(self: Module, category: ItemTypes.Category)
    return self._CategoryToItems[category]
end

function InventoryServiceClient.GetItemsByTab(self: Module, tab: string)
    return self._TabToItems[tab]
end

function InventoryServiceClient.GetItem(self: Module, itemId: ItemTypes.ItemId)
    return self._Items:Get(itemId)
end

function InventoryServiceClient.GetItems(self: Module)
    return self._Items
end

function InventoryServiceClient.SetSelectedItem(self: Module, item: ReactiveItemTypes.ReactiveItem?)
    self._SelectedItem.Value = item
end

function InventoryServiceClient.GetSelectedItem(self: Module)
    return self._SelectedItem.Value
end

function InventoryServiceClient.ObserveSelectedItem(self: Module)
    return self._SelectedItem:Observe()
end

function InventoryServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._InventoryNetworkClient = self._ServiceBag:GetService(require("InventoryNetworkClient"))
    self._Items = ObservableMap.new()
    self._TabToItems = {}
    self._CategoryToItems = {}
    self._SelectedItem = ValueObject.new(nil)

    self.Signals = {
        ItemAdded = Signal.new(),
        ItemRemoved = Signal.new(), 
    } :: any

    self:_SetupItemIndexes()
end

function InventoryServiceClient.Start(self: Module)
    self._InventoryNetworkClient:GetItems():Then(function(packet: InventoryTypesShared.GetItemsRemotePacket)
        self:_AddItems(packet.Items)
    end):Catch(function(err)
        warn("[InventoryServiceClient] GetItems failed:", err)
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
        self:_AddItems(packet.Items)
    end)

    self._InventoryNetworkClient.RemoteEvents.ItemsRemoved:Connect(function(packet: InventoryTypesShared.ItemsRemovedRemotePacket)
        self:_RemoveItems(packet.ItemIds)
    end)
end

return InventoryServiceClient :: Module