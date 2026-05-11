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
local InventoryTypesShared = require("InventoryTypesShared")
local RxPlayerUtils = require("RxPlayerUtils")
local Brio = require("Brio")

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

-- [ Public Functions ] --
function InventoryServiceServer.AddRawItems(self: Module, player: Player, rawItems: { [any]: ItemTypes.RawItem })
    local Items: { ItemTypes.Item } = {}

    for _, rawItem in rawItems do
        table.insert(Items, ItemUtil:ProcessRawItem(rawItem))
    end

    self:AddItems(player, Items)
end

function InventoryServiceServer.AddItems(self: Module, player: Player, items: { [any]: ItemTypes.Item })
    local AddedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}
    local UpdatedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}
    local UpdateInfos: { [ItemTypes.ItemId]: ItemTypes.ItemUpdateInfo } = {}

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
                        if not UpdatedItems[item.Id] then
                            UpdatedItems[item.Id] = StoredItem
                        end

                        local Info = UpdateInfos[item.Id]
                        if Info then
                            Info.Delta += item.Amount
                        else
                            UpdateInfos[item.Id] = { Attribute = "Amount", Delta = item.Amount }
                        end
                    end
                else
                    Data.Inventory[item.Id] = item
                    AddedItems[item.Id] = item
                end
            end,
        })
    end

    if next(AddedItems) then
        self._InventoryNetworkServer:ItemsAdded(player, { Items = AddedItems })
    end

    if next(UpdatedItems) then
        self._InventoryNetworkServer:ItemsUpdated(player, { Items = UpdatedItems, UpdateInfos = UpdateInfos })
    end
end

function InventoryServiceServer.RemoveItems(self: Module, player: Player, items: { ItemTypes.Item })
    local RemovedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}
    local UpdatedItems: { [ItemTypes.ItemId]: ItemTypes.Item } = {}
    local UpdateInfos: { [ItemTypes.ItemId]: ItemTypes.ItemUpdateInfo } = {}

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
                    UpdateInfos[item.Id] = nil
                else
                    StoredItem.Amount -= item.Amount

                    if not UpdatedItems[item.Id] then
                        UpdatedItems[item.Id] = StoredItem
                    end

                    local Info = UpdateInfos[item.Id]
                    if Info then
                        Info.Delta -= item.Amount
                    else
                        UpdateInfos[item.Id] = { Attribute = "Amount", Delta = -item.Amount }
                    end
                end
            end,
        })
    end

    if next(RemovedItems) then
        self._InventoryNetworkServer:ItemsRemoved(player, { Items = RemovedItems })
    end

    if next(UpdatedItems) then
        self._InventoryNetworkServer:ItemsUpdated(player, { Items = UpdatedItems, UpdateInfos = UpdateInfos })
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

    RxPlayerUtils.observePlayersBrio():Subscribe(function(brio: Brio.Brio<Player>)
        local Maid, Player = brio:ToMaidAndValue()

        Maid:Add(function()

        end)
    end)
end

return InventoryServiceServer :: Module
