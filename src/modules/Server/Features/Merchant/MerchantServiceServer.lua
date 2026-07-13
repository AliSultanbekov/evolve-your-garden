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

    PlayerData.Merchant = {
        LastRefresh = DateTime.now().UnixTimestamp,
        BuySlots = BuySlots
    }

    self._MerchantNetworkServer:Refreshed(player, {
        BuySlots = BuySlots
    })
end

function MerchantServiceServer.Buy(self: Module, player: Player, slotId: MerchantTypesShared.SlotId)
    local PlayerData = self._DataServiceServer:GetData(player)
    local MerchantData = PlayerData.Merchant

    local Slot = MerchantData.BuySlots[slotId]
    
    if not Slot then
        return
    end

    if Slot.Left <= 0 then
        return
    end

    local BuyItemConfig = MerchantConfig.BuyItems[Slot.ItemName]

    local Price = BuyItemConfig.Price
    local CurrencyName = BuyItemConfig.CurrencyName
    local Currency = self._InventoryServiceServer:GetItem(player, CurrencyName) :: ItemTypes.CurrencyItem?

    if not Currency then
        return
    end

    local Delta = Currency.Amount - Price

    if Delta < 0 then
        return
    end

    self._InventoryServiceServer:RemoveItems(player, ItemUtil:ProcessRawItem({
        Name = CurrencyName,
        Category = "Currency",
        Amount = Price
    }))
end

function MerchantServiceServer.Sell(self: Module, player: Player, item: ItemTypes.MaterialItem)
    local SellConfigData = MerchantConfig.SellItems[item.Name]

    if not SellConfigData then
        return
    end

    local InventoryItem = self._InventoryServiceServer:GetItem(player, item.Id) :: ItemTypes.MaterialItem

    if InventoryItem.Amount < item.Amount then
        return
    end

    local TotalPrice = SellConfigData.Price * item.Amount

    local Currency: ItemTypes.CurrencyItem = {
        Id = SellConfigData.Currency,
        Category = "Currency" :: "Currency",
        Name = SellConfigData.Currency,
        Amount = TotalPrice,
    }

    self._InventoryServiceServer:RemoveItems(player, { item })
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
        
        return { BuySlots = PlayerData.Merchant.BuySlots }
    end

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