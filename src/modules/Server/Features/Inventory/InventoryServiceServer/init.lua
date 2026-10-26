
--[=[
    @class InventoryServiceServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local ItemUtil = require("ItemUtil")
local ItemConfig = require("ItemConfig")
local PlayerToUserId = require("PlayerToUserId")
local InventoryTypesShared = require("InventoryTypesShared")
local GeneralTypesShared = require("GeneralTypesShared")
local RxPlayerUtils = require("RxPlayerUtils")
local Brio = require("Brio")
local InventoryEnums = require("InventoryEnums")
local GeneralEnums = require("GeneralEnums")
local Signal = require("Signal")
local InventoryConfig = require("InventoryConfig")

local InventoryTypesServer = require("InventoryTypesServer")

local PackActions = require(script.ItemActions._PackActions)
local ToolActions = require(script.ItemActions._ToolActions)

-- [ Constants ] --
local INVENTORY_CAPACITY = 200

-- [ Variables ] --

-- [ Module Table ] --
local InventoryServiceServer = {}

-- [ Types ] --
export type Signals = {
    ItemAdded: Signal.Signal<Player, ItemTypes.Item>,
    ItemRemoved: Signal.Signal<Player, ItemTypes.ItemId>,
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataServiceServer: typeof(require("DataServiceServer")),
    _InventoryNetworkServer: typeof(require("InventoryNetworkServer")),
    _EncyclopediaServiceServer: typeof(require("EncyclopediaServiceServer")),
    _UserIdToItemCount: { [string]: number },
    Signals: Signals,
}

export type Module = typeof(InventoryServiceServer) & ModuleData

-- [ Private Functions ] --
function InventoryServiceServer._GetItem(self: Module, player: Player, itemId: ItemTypes.ItemId): ItemTypes.Item?
    local Data = self._DataServiceServer:GetData(player)

    return Data.Inventory[itemId]
end

function InventoryServiceServer._GetInventoryItemCount(self: Module, player: Player)
    return self._UserIdToItemCount[PlayerToUserId(player)]
end

function InventoryServiceServer._IsInventoryFull(self: Module, player: Player)
    if self:_GetInventoryItemCount(player) >= INVENTORY_CAPACITY then
        return true
    else
        return false
    end
end

function InventoryServiceServer._CanFitItems(self: Module, player: Player, items: { [any]: ItemTypes.Item }): boolean
    local Data = self._DataServiceServer:GetProfile(player).Data
    local PredictedItemCount = self:_GetInventoryItemCount(player)
    local SeenItemIds = {}

    for _, item in items do
        if SeenItemIds[item.Id] then
            continue
        end

        SeenItemIds[item.Id] = true

        if not Data.Inventory[item.Id] then
            PredictedItemCount += 1
        end
    end

    return PredictedItemCount <= INVENTORY_CAPACITY
end

-- [ Public Functions ] --
function InventoryServiceServer.UseAction(self: Module, player: Player, action: string, itemId: ItemTypes.ItemId, params: { [string]: any }?): GeneralTypesShared.DefaultResult
    local PlayerData = self._DataServiceServer:GetData(player)
    local Item = self:_GetItem(player, itemId)

    if not Item then
        return GeneralEnums.Result.Fail
    end

    local Context: InventoryTypesServer.ItemActionContext = {
        PlayerData = PlayerData,
        Item = Item,
        Params = params or {},
        Gateway = {
            AddRawItems = function(items: { [any]: ItemTypes.RawItem }, discover: boolean?): GeneralTypesShared.DefaultResult
                return self:AddRawItems(player, items, discover)
            end,
            AddItems = function(items: { [any]: ItemTypes.Item }, discover: boolean?): GeneralTypesShared.DefaultResult
                return self:AddItems(player, items, discover)
            end,
            RemoveItems = function(items: { [any]: ItemTypes.Item })
                self:RemoveItems(player, items)
            end,
            UpdateItems = function(items: { [any]: ItemTypes.Item })
                self._InventoryNetworkServer:ItemsUpdated(player, { Items = items })
            end,
            IsInventoryFull = function(): boolean
                return self:_IsInventoryFull(player)
            end,
            CanFitItems = function(items: { [any]: ItemTypes.Item }): boolean
                return self:_CanFitItems(player, items)
            end,
        },
    }

    if action == InventoryEnums.Actions.Open then
        if Item.Category ~= "Pack" then
            return GeneralEnums.Result.Fail
        end

        return PackActions.Open(Context)
    elseif action == InventoryEnums.Actions.Delete then
        if Item.Category == "Currency" then
            return GeneralEnums.Result.Fail
        end

        return self:RemoveItems(player, { Item })
    elseif action == InventoryEnums.Actions.UseTool then
        if Item.Category ~= "Tool" then
            return GeneralEnums.Result.Fail
        end

        return ToolActions:Use(Context)
    else
        return GeneralEnums.Result.Fail
    end
end

function InventoryServiceServer.CheckItemExists(self: Module, player: Player, itemId: ItemTypes.ItemId): boolean
    if not self:_GetItem(player, itemId) then
        return false
    else
        return true
    end
end

function InventoryServiceServer.GetItem(self: Module, player: Player, itemId: ItemTypes.ItemId): ItemTypes.Item?
    local Data = self._DataServiceServer:GetData(player)
    local Item = Data.Inventory[itemId]

    if not Item then
        return nil
    end

    return table.clone(Item)
end

function InventoryServiceServer.AddRawItems(
    self: Module, 
    player: Player, 
    rawItems: { [any]: ItemTypes.RawItem },
    discover: boolean?
): GeneralTypesShared.DefaultResult
    local Items: { ItemTypes.Item } = {}

    for _, rawItem in rawItems do
        table.insert(Items, ItemUtil:ProcessRawItem(rawItem))
    end

    return self:AddItems(player, Items, discover)
end

function InventoryServiceServer.AddItems(
    self: Module, 
    player: Player, 
    items: { [any]: ItemTypes.Item },
    discover: boolean?
): GeneralTypesShared.DefaultResult
    local Data = self._DataServiceServer:GetProfile(player).Data
    local UserId = PlayerToUserId(player)
    local ItemCount = self:_GetInventoryItemCount(player)
    local Batch: { [ItemTypes.ItemId]: ItemTypes.Item } = {}
    local PredictedItemCount = ItemCount

    for _, item in items do
        ItemUtil:OnStorageMode(item, {
            ["All"] = function(item: ItemTypes.Item)
                if Batch[item.Id] then
                    return
                end

                Batch[item.Id] = item

                if not Data.Inventory[item.Id] then
                    PredictedItemCount += 1
                end
            end,
            ["Stackable"] = function(item: ItemTypes.StackableItem)
                local ExistingItem = Batch[item.Id] :: ItemTypes.StackableItem

                if ExistingItem == item then
                    return
                end

                (ExistingItem :: ItemTypes.Stackable).Amount = math.clamp(ExistingItem.Amount + item.Amount, 0, ItemConfig.MaxAmount)
            end,
        })
    end

    if PredictedItemCount > INVENTORY_CAPACITY then
        return GeneralEnums.Result.Fail
    end

    local AddedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}
    local UpdatedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}

    if discover then
        self._EncyclopediaServiceServer:DiscoverItems(player, Batch)
    end
    
    -- commit
    for _, item in Batch do
        ItemUtil:OnStorageMode(item, {
            ["All"] = function(item: ItemTypes.Item)
                if Data.Inventory[item.Id] then
                    return
                end

                Data.Inventory[item.Id] = item
                ItemCount += 1
                AddedItems[item.Id] = item
            end,
            ["Stackable"] = function(item: ItemTypes.StackableItem)
                if AddedItems[item.Id] then
                    return
                end

                local StoredItem = Data.Inventory[item.Id] :: ItemTypes.StackableItem

                (StoredItem :: ItemTypes.Stackable).Amount = math.clamp(StoredItem.Amount + item.Amount, 0, ItemConfig.MaxAmount)
                UpdatedItems[item.Id] = StoredItem
            end,
        })
    end

    self._UserIdToItemCount[UserId] = ItemCount

    for _, item in AddedItems do
        self.Signals.ItemAdded:Fire(player, item)
    end

    if next(AddedItems) then
        self._InventoryNetworkServer:ItemsAdded(player, { Items = AddedItems })
    end

    if next(UpdatedItems) then
        self._InventoryNetworkServer:ItemsUpdated(player, { Items = UpdatedItems })
    end

    return GeneralEnums.Result.Success
end

function InventoryServiceServer.RemoveItems(self: Module, player: Player, items: { ItemTypes.Item }): GeneralTypesShared.DefaultResult
    local Data = self._DataServiceServer:GetProfile(player).Data
    local UserId = PlayerToUserId(player)
    
    local RemovedItemIds: { ItemTypes.ItemId } = {}
    local UpdatedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}

    for _, item in items do
        ItemUtil:OnStorageMode(item, {
            Unique = function(item: ItemTypes.UniqueItem)
                if not Data.Inventory[item.Id] then
                    return
                end

                Data.Inventory[item.Id] = nil
                self._UserIdToItemCount[UserId] -= 1
                table.insert(RemovedItemIds, item.Id)
            end,
            Stackable = function(item: ItemTypes.StackableItem)
                local StoredItem = Data.Inventory[item.Id] :: ItemTypes.StackableItem

                if not StoredItem then
                    return
                end

                if StoredItem.Amount <= item.Amount then
                    Data.Inventory[item.Id] = nil
                    self._UserIdToItemCount[UserId] -= 1
                    table.insert(RemovedItemIds, item.Id)
                    UpdatedItems[item.Id] = nil
                else
                    local StoredStackable: ItemTypes.Stackable = StoredItem
                    StoredStackable.Amount -= item.Amount
                    UpdatedItems[item.Id] = StoredItem
                end
            end,
        })
    end

    if next(RemovedItemIds) then
        self._InventoryNetworkServer:ItemsRemoved(player, { ItemIds = RemovedItemIds })

        for _, itemId in RemovedItemIds do
            self.Signals.ItemRemoved:Fire(player, itemId)
        end
    end

    if next(UpdatedItems) then
        self._InventoryNetworkServer:ItemsUpdated(player, { Items = UpdatedItems })
    end

    return GeneralEnums.Result.Success
end

function InventoryServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._DataServiceServer = self._ServiceBag:GetService(require("DataServiceServer"))
    self._InventoryNetworkServer = self._ServiceBag:GetService(require("InventoryNetworkServer"))
    self._EncyclopediaServiceServer = self._ServiceBag:GetService(require("EncyclopediaServiceServer"))
    self._UserIdToItemCount = {}

    self.Signals = {
        ItemAdded = Signal.new(),
        ItemRemoved = Signal.new(),
    } :: any
end

function InventoryServiceServer.Start(self: Module)
    self._InventoryNetworkServer.RemoteFunctions.GetItems = function(player: Player): InventoryTypesShared.GetItemsRemotePacket
        local Data = self._DataServiceServer:GetProfile(player).Data

        return { Items = Data.Inventory }
    end

    self._InventoryNetworkServer.RemoteEvents.UseAction:Connect(function(player: Player, packet: InventoryTypesShared.UseActionRemotePacket)
        if not InventoryConfig.Actions[packet.Action] then
            return
        end
        
        self:UseAction(player, packet.Action, packet.ItemId, packet.Params)
    end)

    RxPlayerUtils.observePlayersBrio():Subscribe(function(brio: Brio.Brio<Player>)
        local Maid, Player = brio:ToMaidAndValue()

        Maid:Add(self._DataServiceServer:OnDataReady(Player, function(Data)
            local UserId = PlayerToUserId(Player)
            local ItemCount = 0
            for _ in Data.Inventory do
                ItemCount += 1
            end

            self._UserIdToItemCount[UserId] = ItemCount

            return function()
                self._UserIdToItemCount[UserId] = nil
            end
        end))
    end)
end

return InventoryServiceServer :: Module
