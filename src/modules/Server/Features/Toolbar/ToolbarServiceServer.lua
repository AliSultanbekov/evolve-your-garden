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
local Signal = require("Signal")

-- [ Constants ] --
local TOOLBAR_TEMPLATE = {}

-- [ Variables ] --

-- [ Module Table ] --
local ToolbarServiceServer = {}

-- [ Types ] --
type Signals = {
    ItemEquipped: Signal.Signal<Player, ItemTypes.ItemId>,
    ItemUnequipped: Signal.Signal<Player, ItemTypes.ItemId>,
}

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
    },
    Signals: Signals
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
    local ToolbarData = PlayerData.Toolbar
    local UserId = PlayerToUserId(player)
    local ItemIdToSlotId = self._PlayersItemIdToSlotId[UserId]
    local EquippedSlotId = self:GetEquippedSlotId(player)

    for slotId, itemId in slots do
        if not ToolbarConfig:IsValidSlotId(slotId) then
            continue
        end

        if not self._InventoryServiceServer:GetItem(player, itemId) then
            continue
        end
        
        if EquippedSlotId == slotId then
            self:UnequipSlot(player)
        end

        ToolbarData[slotId] = itemId
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
    local ToolbarData = PlayerData.Toolbar
    local UserId = PlayerToUserId(player)
    local ItemIdToSlotId = self._PlayersItemIdToSlotId[UserId]
    local EquippedSlotId = self:GetEquippedSlotId(player)

    for _, slotId in slotIds do
        if not ToolbarConfig:IsValidSlotId(slotId) then
            continue
        end
        
        local ItemId = ToolbarData[slotId]

        ToolbarData[slotId] = nil

        if not ItemId then
            continue
        end

        ItemIdToSlotId[ItemId] = nil

        if EquippedSlotId ~= slotId then
            continue
        end

        self._PlayersEquippedSlotIds[UserId] = nil
        self.Signals.ItemUnequipped:Fire(player, ItemId)
    end
end

function ToolbarServiceServer.EquipSlot(self: Module, player: Player, slotId: ToolbarTypesShared.SlotId)
    local PlayerData = self._DataServiceServer:GetData(player)
    local ToolbarData = PlayerData.Toolbar

    if not ToolbarConfig:IsValidSlotId(slotId) then
        return
    end

    local UserId = PlayerToUserId(player)
    local ItemId = ToolbarData[slotId]

    self._PlayersEquippedSlotIds[UserId] = slotId

    if ItemId then
        self.Signals.ItemEquipped:Fire(player, ItemId)
    end
end

function ToolbarServiceServer.UnequipSlot(self: Module, player: Player)
    local PlayerData = self._DataServiceServer:GetData(player)
    local ToolbarData = PlayerData.Toolbar
    local UserId = PlayerToUserId(player)
    local SlotId = self._PlayersEquippedSlotIds[UserId]

    self._PlayersEquippedSlotIds[UserId] = nil

    if SlotId then
        local ItemId = ToolbarData[SlotId]

        if ItemId then
            self.Signals.ItemUnequipped:Fire(player, ItemId)
        end
    end
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
    self.Signals = {
        ItemEquipped = Signal.new(),
        ItemUnequipped = Signal.new(),
    } :: any
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
            local ToolbarData = Data.Toolbar 

            ReconcileUtil:Reconcile(ToolbarData, TOOLBAR_TEMPLATE)

            for slotId, itemId: ItemTypes.ItemId in ToolbarData do
                local SlotIds = {}

                if not self._InventoryServiceServer:GetItem(Player, itemId) then
                    table.insert(SlotIds, slotId)
                end

                self:UnbindSlots(Player, SlotIds)
            end

            return
        end))
    end)
end

return ToolbarServiceServer :: Module
