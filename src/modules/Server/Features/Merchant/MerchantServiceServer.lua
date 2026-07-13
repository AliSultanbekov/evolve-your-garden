local RunService = game:GetService("RunService")
--[=[
    @class MerchantServiceServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local ItemTypes = require("ItemTypes")
local MerchantConfig = require("MerchantConfig")
local RxPlayerUtils = require("RxPlayerUtils")
local Brio = require("Brio")
local Maid = require("Maid")
local ProfileConfig = require("ProfileConfig")
local MerchantTypesShared = require("MerchantTypesShared")
local InventoryTypesShared = require("InventoryTypesShared")
local ChanceClass = require("ChanceClass")
local ItemUtil = require("ItemUtil")
-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local MerchantServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _MerchantNetworkServer: typeof(require("MerchantNetworkServer")),
    _InventoryServiceServer: typeof(require("InventoryServiceServer")),
    _DataServiceServer: typeof(require("DataServiceServer")),
}

export type Module = typeof(MerchantServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function MerchantServiceServer.Refresh(self: Module, player: Player)
    local PlayerData = self._DataServiceServer:GetData(player)

    local ItemPool = {}

    for _, buyConfigData in MerchantConfig.BuyItems do
        ItemPool[buyConfigData.Name] = buyConfigData.Chance
    end
    
    local ChanceObject = ChanceClass.new(ItemPool)
    local BuySlots = {}

    for i = 1, 10 do
        local ItemName = ChanceObject:Choose()
        local BuyConfigData = MerchantConfig.BuyItems[ItemName]
        local Stock = math.random(BuyConfigData.Stock.Min, BuyConfigData.Stock.Max)
        local Id = tostring(i)

        local Slot: MerchantTypesShared.Slot = {
            Id = Id,
            ItemName = ItemName,
            Stock = Stock,
            Left = Stock
        }

        BuySlots[Id] = Slot
    end

    local LastRefresh = DateTime.now().UnixTimestamp

    PlayerData.Merchant = {
        LastRefresh = LastRefresh,
        BuySlots = BuySlots
    }

    self._MerchantNetworkServer:Refreshed(player, {
        BuySlots = BuySlots,
        LastRefresh = LastRefresh
    })
end

function MerchantServiceServer.Buy(self: Module, player: Player, slotId: MerchantTypesShared.SlotId)
    local PlayerData = self._DataServiceServer:GetData(player)
    local MerchantData = PlayerData.Merchant

    if not MerchantData.BuySlots then
        return
    end

    local Slot = MerchantData.BuySlots[slotId]

    if not Slot then
        return
    end

    if Slot.Left <= 0 then
        return
    end

    local BuyItemConfig = MerchantConfig.BuyItems[Slot.ItemName]

    if not BuyItemConfig then
        return
    end

    local Price = BuyItemConfig.Price
    local CurrencyName = BuyItemConfig.Currency
    local Currency = self._InventoryServiceServer:GetItem(player, CurrencyName) :: ItemTypes.CurrencyItem?

    if not Currency then
        return
    end

    if Currency.Amount < Price then
        return
    end

    -- Grant first (capacity-checked); only take payment once the item fits.
    local BoughtItem = ItemUtil:ProcessRawItem(ItemUtil:MakeRawFromName(Slot.ItemName))
    local Result: InventoryTypesShared.Result = self._InventoryServiceServer:AddItems(player, { BoughtItem })

    if Result == "Fail" then
        return
    end

    self._InventoryServiceServer:RemoveItems(player, { ItemUtil:ProcessRawItem({
        Name = CurrencyName,
        Category = "Currency",
        Amount = Price
    }) })

    Slot.Left -= 1

    self._MerchantNetworkServer:Bought(player, {
        SlotId = slotId,
        Left = Slot.Left
    })
end

function MerchantServiceServer.Sell(self: Module, player: Player, itemId: ItemTypes.ItemId, amount: number)
    -- Server-authoritative: everything (name, category, price) derives from the
    -- STORED item at itemId — never from client-declared fields.
    if type(amount) ~= "number" or amount ~= amount or amount <= 0 or amount % 1 ~= 0 then
        return
    end

    local InventoryItem = self._InventoryServiceServer:GetItem(player, itemId) :: ItemTypes.MaterialItem?

    if not InventoryItem then
        return
    end

    if InventoryItem.Category ~= "Material" then
        return
    end

    local SellConfigData = MerchantConfig.SellItems[InventoryItem.Name]

    if not SellConfigData then
        return
    end

    if InventoryItem.Amount < amount then
        return
    end

    local TotalPrice = SellConfigData.Price * amount

    local Currency: ItemTypes.CurrencyItem = {
        Id = SellConfigData.Currency,
        Category = "Currency" :: "Currency",
        Name = SellConfigData.Currency,
        Amount = TotalPrice,
    }

    -- GetItem returns a clone, so adjusting Amount only affects the removal request.
    InventoryItem.Amount = amount

    self._InventoryServiceServer:RemoveItems(player, { InventoryItem })
    self._InventoryServiceServer:AddItems(player, { Currency })
end

function MerchantServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._MerchantNetworkServer = self._ServiceBag:GetService(require("MerchantNetworkServer"))
    self._InventoryServiceServer = self._ServiceBag:GetService(require("InventoryServiceServer"))
    self._DataServiceServer = self._ServiceBag:GetService(require("DataServiceServer"))
end

function MerchantServiceServer.Start(self: Module)
    self._MerchantNetworkServer.RemoteFunctions["GetBuySlots"] = function(player: Player)
        local PlayerData = self._DataServiceServer:GetData(player)

        return {
            BuySlots = PlayerData.Merchant.BuySlots,
            LastRefresh = PlayerData.Merchant.LastRefresh
        }
    end

    self._MerchantNetworkServer.RemoteEvents.Buy:Connect(function(player: Player, packet: MerchantTypesShared.BuyRemotePacket)
        self:Buy(player, packet.SlotId)
    end)

    self._MerchantNetworkServer.RemoteEvents.Sell:Connect(function(player: Player, packet: MerchantTypesShared.SellRemotePacket)
        self:Sell(player, packet.ItemId, packet.Amount)
    end)

    RxPlayerUtils.observePlayersBrio():Subscribe(function(brio: Brio.Brio<Player>)
        local Maid: Maid.Maid, Player: Player = brio:ToMaidAndValue()

        Maid:Add(self._DataServiceServer:OnDataReady(Player, function(data: ProfileConfig.ProfileTemplate)
            local Conn = RunService.Heartbeat:Connect(function(dt: number)
                if data.Merchant.LastRefresh and (data.Merchant.LastRefresh + MerchantConfig.RefreshTime >= DateTime.now().UnixTimestamp) then
                    return
                end

                self:Refresh(Player)
            end)

            return function()
                Conn:Disconnect()
            end
        end))
    end)
end

return MerchantServiceServer :: Module