--[=[
    @class MerchantServiceClient
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local MerchantTypesClient = require("MerchantTypesClient")
local ValueObject = require("ValueObject")
local MerchantTypesShared = require("MerchantTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local MerchantServiceClient = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _MerchantNetworkClient: typeof(require("MerchantNetworkClient")),
    _BuySlots: MerchantTypesClient.ReactiveSlots
}

export type Module = typeof(MerchantServiceClient) & ModuleData

-- [ Private Functions ] --
function MerchantServiceClient._SyncSlotFromPlain(self: Module, reactiveSlot: MerchantTypesClient.ReactiveSlot, slot: MerchantTypesShared.Slot)
    reactiveSlot.ItemName.Value = slot.ItemName
    reactiveSlot.Stock.Value = slot.Stock
    reactiveSlot.Left.Value = slot.Left
end

function MerchantServiceClient._SetupBuySlots(self: Module)
    local BuySlots = {}

    for i = 1, 10 do
        local Id = tostring(i)

        local Slot = {
            Id = Id,
            ItemName = ValueObject.new(),
            Stock = ValueObject.new(0),
            Left = ValueObject.new(0)
        }

        BuySlots[Id] = Slot
    end

    return BuySlots
end

function MerchantServiceClient.UpdateBuySlots(self: Module, buySlots: MerchantTypesShared.Slots)
    for _, slot in buySlots do
        local ReactiveSlot = self._BuySlots[slot.Id]

        self:_SyncSlotFromPlain(ReactiveSlot, slot)
    end
end

-- [ Public Functions ] --
function MerchantServiceClient.GetBuySlots(self: Module)
    return self._BuySlots
end

function MerchantServiceClient.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._MerchantNetworkClient = self._ServiceBag:GetService(require("MerchantNetworkClient"))
    self._BuySlots = self:_SetupBuySlots()
end

function MerchantServiceClient.Start(self: Module)
    self._MerchantNetworkClient:GetSlots():Then(function(packet: MerchantTypesShared.GetBuySlotsRemotePacket)
        self:UpdateBuySlots(packet.BuySlots)
    end)
end

return MerchantServiceClient :: Module