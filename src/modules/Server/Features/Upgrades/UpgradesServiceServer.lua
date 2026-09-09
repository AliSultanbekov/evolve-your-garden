--[=[
    @class UpgradesServiceServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local UpgradesConfig = require("UpgradesConfig")
local ItemTypes = require("ItemTypes")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local UpgradesServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataServiceServer: typeof(require("DataServiceServer")),
    _InventoryServiceServer: typeof(require("InventoryServiceServer")),
}

export type Module = typeof(UpgradesServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function UpgradesServiceServer.GetUpgradeLevel(self: Module, player: Player, upgradeName: string): number
    local Data = self._DataServiceServer:GetData(player)

    return Data.Upgrades[upgradeName]
end

function UpgradesServiceServer.PurchaseUpgrade(self: Module, player: Player, upgradeName: string)
    local UpgradeConfig = UpgradesConfig[upgradeName]

    if not UpgradeConfig then
        return
    end

    local data = self._DataServiceServer:GetProfile(player).Data
    local CurrentLevel = data.Upgrades[upgradeName]

    if not CurrentLevel then
        return
    end

    if CurrentLevel >= UpgradeConfig.MaxLevel then
        return
    end

    -- Currencies live in the Inventory as Currency items (id = name), not in
    -- a separate profile field.
    local CurrencyItem = self._InventoryServiceServer:GetItem(player, UpgradeConfig.Currency) :: ItemTypes.CurrencyItem?

    if not CurrencyItem then
        return
    end

    if CurrencyItem.Category ~= "Currency" then
        return
    end

    local UpgradePrice = UpgradeConfig.GetPrice(CurrentLevel)

    if CurrencyItem.Amount < UpgradePrice then
        return
    end

    -- GetItem returns a clone, so adjusting Amount only affects the removal request.
    CurrencyItem.Amount = UpgradePrice

    self._InventoryServiceServer:RemoveItems(player, { CurrencyItem })

    data.Upgrades[upgradeName] += 1
end

function UpgradesServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._DataServiceServer = self._ServiceBag:GetService(require("DataServiceServer"))
    self._InventoryServiceServer = self._ServiceBag:GetService(require("InventoryServiceServer"))
end

function UpgradesServiceServer.Start(self: Module)
    
end

return UpgradesServiceServer :: Module