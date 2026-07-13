
--[=[
    @class InventoryServiceServer
]=]

-- [ Roblox Services ] --
local Players = game:GetService("Players")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local ItemUtil = require("ItemUtil")
local InventoryTypesShared = require("InventoryTypesShared")
local RxPlayerUtils = require("RxPlayerUtils")
local Brio = require("Brio")
local InventoryEnums = require("InventoryEnums")

local PackActions = require(script.ItemActions._PackActions)

-- [ Constants ] --
local INVENTORY_CAPACITY = 200

-- [ Variables ] --

-- [ Module Table ] --
local InventoryServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataServiceServer: typeof(require("DataServiceServer")),
    _InventoryNetworkServer: typeof(require("InventoryNetworkServer")),
    _PlayersInventoryItemCount: { [Player]: number }
}

export type Module = typeof(InventoryServiceServer) & ModuleData

-- [ Private Functions ] --
function InventoryServiceServer._GetItem(self: Module, player: Player, itemId: ItemTypes.ItemId): ItemTypes.Item?
    local Data = self._DataServiceServer:GetData(player)

    return Data.Inventory[itemId]
end

-- [ Public Functions ] --
function InventoryServiceServer.UseAction(self: Module, player: Player, action: string, itemId: ItemTypes.ItemId, params: { [string]: any }?)
    local PlayerData = self._DataServiceServer:GetData(player)
    local Item = self:_GetItem(player, itemId)

    if not Item then
        return
    end

    local Gateway = {
        AddRawItems = function(items: { [any]: ItemTypes.RawItem })
            self:AddRawItems(player, items)
        end,
        AddItems = function(items: { [any]: ItemTypes.Item })
            self:AddItems(player, items)
        end,
        RemoveItems = function(items: { [any]: ItemTypes.Item })
            self:RemoveItems(player, items)
        end,
        UpdateItems = function(items: { [any]: ItemTypes.Item })
            self._InventoryNetworkServer:ItemsUpdated(player, { Items = items })
        end
    }

    if action == InventoryEnums.Actions.Open then
        if Item.Category ~= "Pack" then
            return
        end

        local Amount = if not params then 1 else if not params["Amount"] then 1 else params["Amount"]

        PackActions.Open({
            PlayerData = PlayerData,
            Item = Item,
            Amount = Amount,
            Gateway = Gateway,
        })
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

    return table.clone(Data.Inventory[itemId])
end

function InventoryServiceServer.AddRawItems(self: Module, player: Player, rawItems: { [any]: ItemTypes.RawItem })
    local Items: { ItemTypes.Item } = {}

    for _, rawItem in rawItems do
        table.insert(Items, ItemUtil:ProcessRawItem(rawItem))
    end

    self:AddItems(player, Items)
end

function InventoryServiceServer.AddItems(self: Module, player: Player, items: { [any]: ItemTypes.Item }, transmitDelay: number?): InventoryTypesShared.Result
    local Data = self._DataServiceServer:GetProfile(player).Data
    local InventoryData = Data.Inventory
    local ItemCount = self._PlayersInventoryItemCount[player]

    if ItemCount >= INVENTORY_CAPACITY then
        return InventoryEnums.Result.Fail
    end

    local NewItemsCount = 0
    for _, item in items do
        if InventoryData[item.Id] then
            NewItemsCount += 1
        end
    end

    if NewItemsCount > INVENTORY_CAPACITY then
        return InventoryEnums.Result.Fail
    end

    local AddedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}
    local UpdatedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}

    for _, item in items do
        ItemUtil:OnStorageMode(item, {
            Unique = function(item: ItemTypes.UniqueItem)
                Data.Inventory[item.Id] = item
                AddedItems[item.Id] = item
            end,
            Stackable = function(item: ItemTypes.StackableItem)
                local StoredItem = Data.Inventory[item.Id] :: ItemTypes.StackableItem

                if StoredItem then
                    StoredItem.Amount += item.Amount

                    if not AddedItems[item.Id] then
                        UpdatedItems[item.Id] = StoredItem
                    end
                else
                    Data.Inventory[item.Id] = item
                    AddedItems[item.Id] = item
                end
            end,
        })
    end

    if next(AddedItems) then
        task.delay(transmitDelay or 0, function()
            if player.Parent ~= Players then
                return
            end

            self._InventoryNetworkServer:ItemsAdded(player, { Items = AddedItems })
        end)
    end

    if next(UpdatedItems) then
        task.delay(transmitDelay or 0, function()
            if player.Parent ~= Players then
                return
            end
            
            self._InventoryNetworkServer:ItemsUpdated(player, { Items = UpdatedItems })
        end)
    end

    return InventoryEnums.Result.Success
end

function InventoryServiceServer.RemoveItems(self: Module, player: Player, items: { ItemTypes.Item })
    local Data = self._DataServiceServer:GetProfile(player).Data
    
    local RemovedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}
    local UpdatedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}

    for _, item in items do
        ItemUtil:OnStorageMode(item, {
            Unique = function(item: ItemTypes.UniqueItem)
                if not Data.Inventory[item.Id] then
                    return
                end

                Data.Inventory[item.Id] = nil
                self._PlayersInventoryItemCount[player] -= 1
                RemovedItems[item.Id] = item
            end,
            Stackable = function(item: ItemTypes.StackableItem)
                local StoredItem = Data.Inventory[item.Id] :: ItemTypes.StackableItem

                if not StoredItem then
                    return
                end

                if StoredItem.Amount <= item.Amount then
                    Data.Inventory[item.Id] = nil
                    self._PlayersInventoryItemCount[player] -= 1
                    RemovedItems[item.Id] = StoredItem
                    UpdatedItems[item.Id] = nil
                else
                    StoredItem.Amount -= item.Amount
                    UpdatedItems[item.Id] = StoredItem
                end
            end,
        })
    end

    if next(RemovedItems) then
        self._InventoryNetworkServer:ItemsRemoved(player, { Items = RemovedItems })
    end

    if next(UpdatedItems) then
        self._InventoryNetworkServer:ItemsUpdated(player, { Items = UpdatedItems })
    end
end

function InventoryServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._DataServiceServer = self._ServiceBag:GetService(require("DataServiceServer"))
    self._InventoryNetworkServer = self._ServiceBag:GetService(require("InventoryNetworkServer"))
    self._PlayersInventoryItemCount = {}
end

function InventoryServiceServer.Start(self: Module)
    self._InventoryNetworkServer.RemoteFunctions.GetItems = function(player: Player): InventoryTypesShared.GetItemsRemotePacket
        local Data = self._DataServiceServer:GetProfile(player).Data

        return { Items = Data.Inventory }
    end

    self._InventoryNetworkServer.RemoteEvents.UseAction:Connect(function(player: Player, packet: InventoryTypesShared.UseActionRemotePacket)
        self:UseAction(player, packet.Action, packet.ItemId, packet.Params)
    end)

    RxPlayerUtils.observePlayersBrio():Subscribe(function(brio: Brio.Brio<Player>)
        local Maid, Player = brio:ToMaidAndValue()
        --local UserId = PlayerToUserId(Player) // might use in future

        Maid:Add(self._DataServiceServer:OnDataReady(Player, function(Data)
            local ItemCount = 0
            for _ in Data.Inventory do
                ItemCount += 1
            end

            self._PlayersInventoryItemCount[Player] = ItemCount

            return function()
                self._PlayersInventoryItemCount[Player] = nil
            end
        end))
    end)
end

return InventoryServiceServer :: Module
