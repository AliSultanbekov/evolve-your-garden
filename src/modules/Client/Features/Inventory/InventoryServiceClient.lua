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
local LinkedListClass = require("LinkedListClass")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local InventoryServiceClient = {}

-- [ Types ] --
type Signals = {
    ItemAdded: Signal.Signal<ReactiveItemTypes.ReactiveItem>,
    ItemRemoved: Signal.Signal<ItemTypes.ItemId>,
    ItemCollected: Signal.Signal<InventoryTypesClient.CollectedItem>,
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _InventoryNetworkClient: typeof(require("InventoryNetworkClient")),
    _Items: ReactiveItemTypes.ReactiveItems,
    _TabToItems: InventoryTypesClient.TabToItems,
    _CategoryToItems: InventoryTypesClient.CategoryToItems,
    _SelectedItem: ValueObject.ValueObject<ReactiveItemTypes.ReactiveItem?>,
    _PendingItemEntries: { [ItemTypes.ItemId]: LinkedListClass.Object<InventoryTypesClient.PendingItemEntry> },
    Signals: Signals,
}

export type Module = typeof(InventoryServiceClient) & ModuleData

-- [ Private Functions ] --
function InventoryServiceClient._ClearPending(self: Module, itemId: ItemTypes.ItemId)
    local Head = self._PendingItemEntries[itemId] :: LinkedListClass.Object<InventoryTypesClient.PendingItemEntry>

    if not Head then
        return
    end

    for Node in Head:IterateForward() do
        task.cancel(Node.Value.Thread)
    end

    self._PendingItemEntries[itemId] = nil
end

function InventoryServiceClient._AttachPending(
    self: Module,
    itemId: ItemTypes.ItemId,
    node: LinkedListClass.Object<InventoryTypesClient.PendingItemEntry>
)
    local Head = self._PendingItemEntries[itemId]

    if Head then
        Head:GetLast():AttachAfter(node)
    else
        self._PendingItemEntries[itemId] = node
    end
end

function InventoryServiceClient._DetachPending(
    self: Module,
    itemId: ItemTypes.ItemId,
    node: LinkedListClass.Object<InventoryTypesClient.PendingItemEntry>
)
    local Next = node:Detach()

    if self._PendingItemEntries[itemId] ~= node then
        return
    end

    if Next then
        self._PendingItemEntries[itemId] = Next
    else
        self._PendingItemEntries[itemId] = nil
    end
end

function InventoryServiceClient._SyncItem(self: Module, shownItem: ReactiveItemTypes.ReactiveItem, item: ItemTypes.Item)
    local Amount = (shownItem :: any).Amount
    local PreviousAmount = Amount and Amount.Value

    ReactiveItemUtil:SyncFromPlain(shownItem, item)

    -- Packets carry totals, so the amount gained is the difference from what was shown
    if Amount and Amount.Value > PreviousAmount then
        self.Signals.ItemCollected:Fire({
            Name = item.Name,
            Category = item.Category,
            Amount = Amount.Value - PreviousAmount,
        })
    end
end

function InventoryServiceClient._CancelOlderPending(
    self: Module,
    itemId: ItemTypes.ItemId,
    node: LinkedListClass.Object<InventoryTypesClient.PendingItemEntry>
)
    local Older = node:GetPrevious()

    while Older do
        local Previous = Older:GetPrevious()

        task.cancel(Older.Value.Thread)
        self:_DetachPending(itemId, Older)

        Older = Previous
    end
end

function InventoryServiceClient._AddToPending(self: Module, items: { [any]: ItemTypes.Item }, revealAt: number)
    local function SpawnThread(
        itemId: ItemTypes.ItemId,
        node: LinkedListClass.Object<InventoryTypesClient.PendingItemEntry>
    )
        return task.delay(math.max(0, revealAt - workspace:GetServerTimeNow()), function()
            -- Nodes are in arrival order and carry totals, so older nodes are out of date
            self:_CancelOlderPending(itemId, node)
            self:_DetachPending(itemId, node)

            local ShownItem = self._Items:Get(itemId)

            if ShownItem then
                self:_SyncItem(ShownItem, node.Value.Item)
            else
                self:_AddItems({ node.Value.Item })
            end
        end)
    end

    for _, item in items do
        local Node = LinkedListClass.new()

        Node:SetValue({
            Item = item,
            RevealAt = revealAt,
            Thread = SpawnThread(item.Id, Node)
        })

        self:_AttachPending(item.Id, Node)
    end
end

function InventoryServiceClient._SetupItemIndexes(self: Module)
    for tab, _ in InventoryConfigClient.TabsConfig do
        self._TabToItems[tab] = ObservableMap.new()
    end

    for _, category: ItemTypes.Category in ItemConfig.Categories :: { ItemTypes.Category } do
        self._CategoryToItems[category] = ObservableMap.new()
    end
end

function InventoryServiceClient._AddItems(self: Module, items: { [any]: ItemTypes.Item }, revealAt: number?, isInitialLoad: boolean?)
    if revealAt then
        self:_AddToPending(items, revealAt)
    else
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

            if not isInitialLoad then
                self.Signals.ItemCollected:Fire({
                    Name = item.Name,
                    Category = item.Category,
                    Amount = (item :: any).Amount or 1,
                })
            end
        end
    end
end

function InventoryServiceClient._UpdateItems(self: Module, items: { [any]: ItemTypes.Item }, revealAt: number?)
    if revealAt then
        self:_AddToPending(items, revealAt)
    else
        for _, item in items do
            local WasPending = self._PendingItemEntries[item.Id] ~= nil

            self:_ClearPending(item.Id)
    
            local Item = self._Items:Get(item.Id)
    
            if Item then
                self:_SyncItem(Item, item)
            elseif WasPending then
                self:_AddItems({ item })
            end
        end
    end
end

function InventoryServiceClient._RemoveItems(self: Module, itemIds: { ItemTypes.ItemId })
    for _, itemId in itemIds do
        self:_ClearPending(itemId)

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
    self._PendingItemEntries = {}

    self.Signals = {
        ItemAdded = Signal.new(),
        ItemRemoved = Signal.new(), 
        ItemCollected = Signal.new(),
    } :: any

    self:_SetupItemIndexes()
end

function InventoryServiceClient.Start(self: Module)
    self._InventoryNetworkClient:GetItems():Then(function(packet: InventoryTypesShared.GetItemsRemotePacket)
        self:_AddItems(packet.Items, nil, true)
    end):Catch(function(err)
        warn("[InventoryServiceClient] GetItems failed:", err)
    end)

    self._InventoryNetworkClient.RemoteEvents.ItemsUpdated:Connect(function(packet: InventoryTypesShared.ItemsUpdatedRemotePacket)
        self:_UpdateItems(packet.Items, packet.RevealAt)
    end)    

    self._InventoryNetworkClient.RemoteEvents.ItemsAdded:Connect(function(packet: InventoryTypesShared.ItemsAddedRemotePacket)
        self:_AddItems(packet.Items, packet.RevealAt)
    end)

    self._InventoryNetworkClient.RemoteEvents.ItemsRemoved:Connect(function(packet: InventoryTypesShared.ItemsRemovedRemotePacket)
        self:_RemoveItems(packet.ItemIds)
    end)
end

return InventoryServiceClient :: Module