
--[=[
    @class PackStoreService
]=]

-- [ Roblox Services ] --
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local RxPlayerUtils = require("RxPlayerUtils")
local Brio = require("Brio")
local PackStoreConfig = require("PackStoreConfig")
local PackStoreTypesShared = require("PackStoreTypesShared")
local InventoryTypesShared = require("InventoryTypesShared")
local ItemUtil = require("ItemUtil")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PackStoreService = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _PackStoreNetworkServer: typeof(require("PackStoreNetworkServer")),
    _DataServiceServer: typeof(require("DataServiceServer")),
    _JavaBackendServiceServer: typeof(require("JavaBackendServiceServer")),
    _InventoryServiceServer: typeof(require("InventoryServiceServer")),
    _CurrentSale: PackStoreTypesShared.SaleState,
}

export type Module = typeof(PackStoreService) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function PackStoreService.BuyPack(self: Module, player: Player, packId: PackStoreTypesShared.PackId)
    local PlayerData = self._DataServiceServer:GetData(player)
    local PackStoreData = PlayerData.PackStore
    local Pack = PackStoreData.Packs[packId]

    if not Pack then
        return
    end

    if Pack.Left <= 0 then
        return
    end

    if PackStoreData.SaleId ~= self._CurrentSale.SaleId then
        return
    end

    if self._CurrentSale.StartTime + PackStoreConfig.SaleDuration <= DateTime.now().UnixTimestamp then
        return
    end

    local PriceCategoryConfig = PackStoreConfig.Prices[Pack.Category]

    if not PriceCategoryConfig then
        return
    end

    local PackPriceConfig = PriceCategoryConfig[Pack.Name]

    if not PackPriceConfig then
        return
    end

    local PackPrice = PackPriceConfig.Amount
    local Currency = PackPriceConfig.Currency

    local CurrencyItem = self._InventoryServiceServer:GetItem(player, Currency)

    if not CurrencyItem then
        return
    end

    if CurrencyItem.Category ~= "Currency" then
        return
    end

    if CurrencyItem.Amount < PackPrice then
        return
    end

    -- Grant first (capacity-checked); only take payment and stock once the
    -- pack actually fits in the inventory.
    local PackItem = ItemUtil:ProcessRawItem({
        Category = "Pack",
        Name = Pack.Name,
        Amount = 1,
    })
    local Result: InventoryTypesShared.Result = self._InventoryServiceServer:AddItems(player, { PackItem })

    if Result == "Fail" then
        return
    end

    -- GetItem returns a clone, so adjusting Amount only affects the removal request.
    CurrencyItem.Amount = PackPrice

    self._InventoryServiceServer:RemoveItems(player, {CurrencyItem})

    Pack.Left -= 1

    self._PackStoreNetworkServer:PackBought(player, { PackId = packId, Left = Pack.Left })
end

function PackStoreService.Refresh(
    self: Module, 
    saleId: PackStoreTypesShared.SaleId, 
    globalPacks: PackStoreTypesShared.GlobalPacks,
    startTime: number,
    players: { Player }
)
    self._CurrentSale = {
        SaleId = saleId,
        GlobalPacks = globalPacks,
        StartTime = startTime,
    }

    for _, player in players do
        local PlayerData = self._DataServiceServer:GetData(player)

        if PlayerData.PackStore.SaleId == saleId then
            continue
        end

        local Packs: { [PackStoreTypesShared.PackId]: PackStoreTypesShared.Pack} = {}

        for _, pack in globalPacks do
            Packs[pack.Id] = pack
        end

        for category: PackStoreTypesShared.Category, packs in PackStoreConfig.LocalCategories do
            for _, packconfig in packs do
                local Id = HttpService:GenerateGUID(false)
                local Stock = math.random(packconfig.Stock.Min, packconfig.Stock.Max)

                Packs[Id] = {
                    Id = Id,
                    Category = category,
                    Name = packconfig.PackName,
                    Stock = Stock,
                    Left = Stock,
                }
            end
        end
        
        PlayerData.PackStore = {
            SaleId = saleId,
            Packs = Packs,
        }

        self._PackStoreNetworkServer:Refreshed(player, { Packs = Packs, StartTime = startTime })
    end
end

function PackStoreService.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._PackStoreNetworkServer = self._ServiceBag:GetService(require("PackStoreNetworkServer"))
    self._JavaBackendServiceServer = self._ServiceBag:GetService(require("JavaBackendServiceServer"))
    self._DataServiceServer = self._ServiceBag:GetService(require("DataServiceServer"))
    self._InventoryServiceServer = self._ServiceBag:GetService(require("InventoryServiceServer"))
    self._CurrentSale = {
        SaleId = "",
        GlobalPacks = {},
        StartTime = 0
    }
end

function PackStoreService.Start(self: Module)
    self._PackStoreNetworkServer.RemoteFunctions.GetCurrentSale = function(player: Player)
        local PlayerData = self._DataServiceServer:GetData(player)
        local PackStoreData = PlayerData.PackStore

        return {
            Packs = PackStoreData.Packs,
            StartTime = self._CurrentSale.StartTime,
        }
    end
    
    task.spawn(function()
        local Packet = self._JavaBackendServiceServer:GetPackStoreCurrentSale()
    
        self:Refresh(Packet.SaleId, Packet.Packs, Packet.StartTime, Players:GetPlayers())
    
        self._JavaBackendServiceServer:SubsribeToPackStoreRefreshed(function(packet)
            self:Refresh(packet.SaleId, packet.Packs, packet.StartTime, Players:GetPlayers())
        end)
    
        RxPlayerUtils.observePlayersBrio():Subscribe(function(brio: Brio.Brio<Player>)
            local Maid, Player = brio:ToMaidAndValue()
    
            local PlayerData = self._DataServiceServer:GetData(Player)
    
            if PlayerData.PackStore.SaleId ~= self._CurrentSale.SaleId then
                self:Refresh(self._CurrentSale.SaleId, self._CurrentSale.GlobalPacks, self._CurrentSale.StartTime, { Player })
            end
    
            Maid:Add(function()
                
            end)
        end)

        self._PackStoreNetworkServer.RemoteEvents.BuyPack:Connect(function(player: Player, packet: PackStoreTypesShared.BuyPackRemotePacket)
            self:BuyPack(player, packet.PackId)
        end)
    end)
end

return PackStoreService :: Module