--[=[
    @class ToolbarServiceClient

    Owns toolbar state: the slot layout mirror and which slot is equipped.
    The equipped SLOT is the one truth; the equipped item id is derived from
    it (slot contents changing re-derives automatically). Server mirrors the
    slot, so only slot changes cross the network.
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ValueObject = require("ValueObject")
local Rx = require("Rx")
local ItemTypes = require("ItemTypes")
local ToolbarTypesShared = require("ToolbarTypesShared")
local ToolbarTypesClient = require("ToolbarTypesClient")
local ToolbarConfig = require("ToolbarConfig")
local Observable = require("Observable")
local ReactiveItemTypes = require("ReactiveItemTypes")
local Maid = require("Maid")
local Signal = require("Signal")
local ItemConfig = require("ItemConfig")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ToolbarServiceClient = {}

-- [ Types ] --
type Signals = {
    ItemEquipped: Signal.Signal<ItemTypes.ItemId>,
    ItemUnequipped: Signal.Signal<ItemTypes.ItemId>
}

type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _ToolbarNetworkClient: typeof(require("ToolbarNetworkClient")),
    _InventoryServiceClient: typeof(require("InventoryServiceClient")),
    _Maid: Maid.Maid,
    _Slots: ToolbarTypesClient.ReactiveSlots,
    _ItemIdToSlotId: {
        [ItemTypes.ItemId]: ToolbarTypesShared.SlotId
    },
    _EquippedSlotId: ValueObject.ValueObject<ToolbarTypesShared.SlotId?>,
    Signals: Signals,
}

export type Module = typeof(ToolbarServiceClient) & ModuleData

-- [ Private Functions ] --
function ToolbarServiceClient._SetupSlots(self: Module)
    local Slots = {}

    for _, slotId in ToolbarConfig.SlotOrder do
        Slots[slotId] = ValueObject.new()
    end

    return Slots :: any
end

function ToolbarServiceClient._GetSlotIdFromItemId(self: Module, itemId: ItemTypes.ItemId)
    return self._ItemIdToSlotId[itemId]
end

function ToolbarServiceClient._SetSlotItemId(self: Module, slotId: ToolbarTypesShared.SlotId, itemId: ItemTypes.ItemId?)
    local Slot = self._Slots[slotId]

    if not Slot then
        return
    end

    local StaleItemId = Slot.Value

    if StaleItemId == itemId then
        return
    end

    if itemId then
        local PreviousSlotId = self._ItemIdToSlotId[itemId]

        if PreviousSlotId and PreviousSlotId ~= slotId then
            self:_SetSlotItemId(PreviousSlotId, nil)
        end
    end

    if StaleItemId then
        self._ItemIdToSlotId[StaleItemId] = nil
    end

    Slot.Value = itemId

    if itemId then
        self._ItemIdToSlotId[itemId] = slotId
    end

    if self._EquippedSlotId.Value == slotId then
        if StaleItemId then
            self.Signals.ItemUnequipped:Fire(StaleItemId)
        end

        if itemId then
            self.Signals.ItemEquipped:Fire(itemId)
        end
    end
end

-- [ Public Functions ] --
function ToolbarServiceClient.ObserveEquippedItemHasTag(self: Module, tag: string): Observable.Observable<boolean>
    return self:ObserveEquippedItem():Pipe({
        Rx.map(function(item: ReactiveItemTypes.ReactiveItem?)
            if not item then
                return false
            end

            return ItemConfig:HasTag(item.Name, tag)
        end) :: any,
        Rx.distinct() :: any,
    }) :: any
end

function ToolbarServiceClient.ObserveEquippedItem(self: Module): Observable.Observable<ReactiveItemTypes.ReactiveItem>
    return self:ObserveEquippedItemId():Pipe({
        Rx.switchMap(function(itemId: ItemTypes.ItemId?)
            if not itemId then
                return Rx.of(nil) :: any
            end

            return self._InventoryServiceClient:GetItems():ObserveAtKey(itemId)
        end) :: any,
        Rx.distinct() :: any,
    })
end

function ToolbarServiceClient.ObserveEquippedItemId(self: Module)
    return self._EquippedSlotId:Observe():Pipe({
        Rx.switchMap(function(slotId: ToolbarTypesShared.SlotId?)
            if not slotId then
                return Rx.of(nil) :: any
            end

            return self._Slots[slotId]:Observe()
        end) :: any,
        Rx.distinct() :: any,
    })
end

function ToolbarServiceClient.ObserveItemFromSlotId(self: Module, slotId: ToolbarTypesShared.SlotId)
    local Slot = self._Slots[slotId]

    if not Slot then
        return Rx.of(nil) :: any
    end

    return Slot:Observe():Pipe({
        Rx.switchMap(function(itemId: ItemTypes.ItemId?)
            if not itemId then
                return Rx.of(nil) :: any
            end

            return self._InventoryServiceClient:GetItems():ObserveAtKey(itemId)
        end) :: any,
        Rx.distinct() :: any,
    }) :: any
end

function ToolbarServiceClient.GetEquippedItem(self: Module): ReactiveItemTypes.ReactiveItem?
    local SlotId = self:GetEquippedSlotId()

    if not SlotId then
        return
    end

    local Item = self:GetItemFromSlotId(SlotId)

    return Item
end

function ToolbarServiceClient.GetEquippedItemId(self: Module): ItemTypes.ItemId?
    local SlotId = self:GetEquippedSlotId()

    if not SlotId then
        return
    end

    return self._Slots[SlotId].Value
end

function ToolbarServiceClient.GetItemFromSlotId(self: Module, slotId: ToolbarTypesShared.SlotId): ReactiveItemTypes.ReactiveItem?
    local Slot = self._Slots[slotId]
    local ItemId = Slot.Value

    if not ItemId then
        return
    end

    return self._InventoryServiceClient:GetItem(ItemId)
end

function ToolbarServiceClient.ObserveEquippedSlotId(self: Module)
    return self._EquippedSlotId:Observe()
end

function ToolbarServiceClient.GetEquippedSlotId(self: Module): ToolbarTypesShared.SlotId?
    return self._EquippedSlotId.Value
end

function ToolbarServiceClient.GetSlot(self: Module, slotId: ToolbarTypesShared.SlotId)
    return self._Slots[slotId]
end

function ToolbarServiceClient.EquipSlot(self: Module, slotId: ToolbarTypesShared.SlotId)
    if not ToolbarConfig:IsValidSlotId(slotId) then
        return
    end

    if self._EquippedSlotId.Value == slotId then
        self:UnequipSlot()
        return
    end

    self._EquippedSlotId.Value = slotId
    self._ToolbarNetworkClient:EquipSlot({ SlotId = slotId })

    local ItemId = self._Slots[slotId].Value

    if ItemId then
        self.Signals.ItemEquipped:Fire(ItemId)
    end
end

function ToolbarServiceClient.UnequipSlot(self: Module)
    local EquippedSlotId = self._EquippedSlotId.Value

    if not EquippedSlotId then
        return
    end

    self._EquippedSlotId.Value = nil
    self._ToolbarNetworkClient:UnequipSlot()

    local ItemId = self._Slots[EquippedSlotId].Value

    if ItemId then
        self.Signals.ItemUnequipped:Fire(ItemId)
    end
end

function ToolbarServiceClient.BindSlot(self: Module, slotId: ToolbarTypesShared.SlotId, itemId: ItemTypes.ItemId)
    if not ToolbarConfig:IsValidSlotId(slotId) then
        return
    end

    self:_SetSlotItemId(slotId, itemId)
    self._ToolbarNetworkClient:BindSlots({ Slots = { [slotId] = itemId } })
end

function ToolbarServiceClient.UnbindSlot(self: Module, slotId: ToolbarTypesShared.SlotId)
    if not ToolbarConfig:IsValidSlotId(slotId) then
        return
    end

    self:_SetSlotItemId(slotId, nil)
    self._ToolbarNetworkClient:UnbindSlots({ SlotIds = { slotId } })
end

function ToolbarServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._ToolbarNetworkClient = self._ServiceBag:GetService(require("ToolbarNetworkClient"))
    self._InventoryServiceClient = self._ServiceBag:GetService(require("InventoryServiceClient"))
    self._Maid = Maid.new()
    self._Slots = self:_SetupSlots()
    self._ItemIdToSlotId = {}
    self._EquippedSlotId = ValueObject.new(nil)
    self.Signals = {
        ItemEquipped = Signal.new(),
        ItemUnequipped = Signal.new(),
    } :: any
end

function ToolbarServiceClient.Start(self: Module)
    self._ToolbarNetworkClient:GetSlots():Then(function(packet: ToolbarTypesShared.GetSlotsRemotePacket)
        for slotId, itemId in packet.Slots do
            self:_SetSlotItemId(slotId, itemId)
        end
    end)

    self._Maid:Add(self._InventoryServiceClient.Signals.ItemRemoved:Connect(function(itemId: ItemTypes.ItemId)
        local SlotId = self:_GetSlotIdFromItemId(itemId)

        if SlotId then
            self:_SetSlotItemId(SlotId, nil)
        end
    end))
end

return ToolbarServiceClient :: Module
