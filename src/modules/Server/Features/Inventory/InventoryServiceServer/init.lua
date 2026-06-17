
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

-- [ Variables ] --

-- [ Module Table ] --
local InventoryServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataServiceServer: typeof(require("DataServiceServer")),
    _InventoryNetworkServer: typeof(require("InventoryNetworkServer")),
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

function InventoryServiceServer.AddItems(self: Module, player: Player, items: { [any]: ItemTypes.Item }, transmitDelay: number?)
    local AddedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}
    local UpdatedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}

    local Data = self._DataServiceServer:GetProfile(player).Data

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
end

function InventoryServiceServer.RemoveItems(self: Module, player: Player, items: { ItemTypes.Item })
    local RemovedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}
    local UpdatedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}

    local Data = self._DataServiceServer:GetProfile(player).Data

    for _, item in items do
        ItemUtil:OnStorageMode(item, {
            Unique = function(item: ItemTypes.UniqueItem)
                if not Data.Inventory[item.Id] then
                    return
                end

                Data.Inventory[item.Id] = nil
                RemovedItems[item.Id] = item
            end,
            Stackable = function(item: ItemTypes.StackableItem)
                local StoredItem = Data.Inventory[item.Id] :: ItemTypes.StackableItem

                if not StoredItem then
                    return
                end

                if StoredItem.Amount <= item.Amount then
                    Data.Inventory[item.Id] = nil
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
        local Maid, _Player = brio:ToMaidAndValue()

        --[[self:AddRawItems(Player, {
            ItemUtil:MakeRawFromName("Snow Blossom")
        })]]

        Maid:Add(function()
            
        end)
    end)
end

return InventoryServiceServer :: Module
