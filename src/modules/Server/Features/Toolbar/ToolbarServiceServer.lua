--[=[
    @class ToolbarServiceServer

    Server mirror of toolbar state: persisted slot bindings (Data.Toolbar)
    and a per-player equipped-slot cache for validation/cosmetics. The
    equipped item is always derived from the slot, never stored.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local RxPlayerUtils = require("RxPlayerUtils")
local Brio = require("Brio")
local PlayerToUserId = require("PlayerToUserId")
local ToolbarTypesShared = require("ToolbarTypesShared")
local ToolbarConfig = require("ToolbarConfig")
local ReconcileUtil = require("ReconcileUtil")

-- [ Constants ] --
local TOOLBAR_TEMPLATE = {}

-- [ Variables ] --

-- [ Module Table ] --
local ToolbarServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _InventoryServiceServer: typeof(require("InventoryServiceServer")),
    _DataServiceServer: typeof(require("DataServiceServer")),
    _ToolbarNetworkServer: typeof(require("ToolbarNetworkServer")),
    _PlayersItemIdToSlotId: {
        [string]: {
            [ItemTypes.ItemId]: ToolbarTypesShared.SlotId
        }
    },
    _PlayersEquippedSlotIds: {
        [string]: ToolbarTypesShared.SlotId
    }
}

export type Module = typeof(ToolbarServiceServer) & ModuleData

-- [ Private Functions ] --
function ToolbarServiceServer._GetSlotIdFromItemId(self: Module, player: Player, itemId: ItemTypes.ItemId)
    local UserId = PlayerToUserId(player)
    local ItemIdToSlotId = self._PlayersItemIdToSlotId[UserId]

    return ItemIdToSlotId[itemId]
end

-- [ Public Functions ] --
function ToolbarServiceServer.GetEquippedSlotId(self: Module, player: Player): ToolbarTypesShared.SlotId?
    local UserId = PlayerToUserId(player)

    return self._PlayersEquippedSlotIds[UserId]
end

function ToolbarServiceServer.GetEquippedItemId(self: Module, player: Player): ItemTypes.ItemId?
    local SlotId = self:GetEquippedSlotId(player)

    if not SlotId then
        return nil
    end

    local Data = self._DataServiceServer:GetData(player)

    return Data.Toolbar[SlotId]
end

function ToolbarServiceServer.BindSlots(
    self: Module,
    player: Player,
    slots: {
        [ToolbarTypesShared.SlotId]: ItemTypes.ItemId
    }
)
    local PlayerData = self._DataServiceServer:GetData(player)
    local Slots = PlayerData.Toolbar
    local UserId = PlayerToUserId(player)
    local ItemIdToSlotId = self._PlayersItemIdToSlotId[UserId]

    for slotId, itemId in slots do
        if not ToolbarConfig:IsValidSlotId(slotId) then
            continue
        end

        if not self._InventoryServiceServer:GetItem(player, itemId) then
            continue
        end

        Slots[slotId] = itemId
        ItemIdToSlotId[itemId] = slotId
    end
end

function ToolbarServiceServer.UnbindSlots(
    self: Module,
    player: Player,
    slotIds: {
        [any]: ToolbarTypesShared.SlotId
    }
)
    local PlayerData = self._DataServiceServer:GetData(player)
    local Slots = PlayerData.Toolbar
    local UserId = PlayerToUserId(player)
    local ItemIdToSlotId = self._PlayersItemIdToSlotId[UserId]

    for _, slotId in slotIds do
        if not ToolbarConfig:IsValidSlotId(slotId) then
            continue
        end
        
        local ItemId = Slots[slotId]

        Slots[slotId] = nil

        if ItemId then
            ItemIdToSlotId[ItemId] = nil
        end
    end
end

function ToolbarServiceServer.EquipSlot(self: Module, player: Player, slotId: ToolbarTypesShared.SlotId)
    if not ToolbarConfig:IsValidSlotId(slotId) then
        return
    end

    local UserId = PlayerToUserId(player)

    self._PlayersEquippedSlotIds[UserId] = slotId
end

function ToolbarServiceServer.UnequipSlot(self: Module, player: Player)
    local UserId = PlayerToUserId(player)

    self._PlayersEquippedSlotIds[UserId] = nil
end

function ToolbarServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._InventoryServiceServer = self._ServiceBag:GetService(require("InventoryServiceServer"))
    self._DataServiceServer = self._ServiceBag:GetService(require("DataServiceServer"))
    self._ToolbarNetworkServer = self._ServiceBag:GetService(require("ToolbarNetworkServer"))
    self._PlayersItemIdToSlotId = {}
    self._PlayersEquippedSlotIds = {}
end

function ToolbarServiceServer.Start(self: Module)
    self._ToolbarNetworkServer.RemoteFunctions["GetSlots"] = function(player: Player)
        local Data = self._DataServiceServer:GetData(player)

        return {
            Slots = Data.Toolbar
        }
    end

    self._ToolbarNetworkServer.RemoteEvents.BindSlots:Connect(function(player: Player, packet)
        self:BindSlots(player, packet.Slots)
    end)

    self._ToolbarNetworkServer.RemoteEvents.UnbindSlots:Connect(function(player: Player, packet)
        self:UnbindSlots(player, packet.SlotIds)
    end)

    self._ToolbarNetworkServer.RemoteEvents.EquipSlot:Connect(function(player: Player, packet)
        self:EquipSlot(player, packet.SlotId)
    end)

    self._ToolbarNetworkServer.RemoteEvents.UnequipSlot:Connect(function(player: Player)
        self:UnequipSlot(player)
    end)

    self._InventoryServiceServer.Signals.ItemRemoved:Connect(function(player: Player, itemId: ItemTypes.ItemId)
        local SlotId = self:_GetSlotIdFromItemId(player, itemId)

        if not SlotId then
            return
        end

        self:UnbindSlots(player, { SlotId } )
    end)

    RxPlayerUtils.observePlayersBrio():Subscribe(function(brio: Brio.Brio<Player>)
        local Maid, Player = brio:ToMaidAndValue()
        local UserId = PlayerToUserId(Player)

        self._PlayersItemIdToSlotId[UserId] = {}

        Maid:Add(function()
            self._PlayersEquippedSlotIds[UserId] = nil
            self._PlayersItemIdToSlotId[UserId] = nil
        end)

        Maid:Add(self._DataServiceServer:OnDataReady(Player, function(Data)
            ReconcileUtil:Reconcile(Data.Toolbar, TOOLBAR_TEMPLATE)

            return
        end))
    end)
end

return ToolbarServiceServer :: Module
