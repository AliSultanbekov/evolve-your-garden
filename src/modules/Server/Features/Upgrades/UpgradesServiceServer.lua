--[=[
    @class UpgradeServiceServer
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ServiceBag = require("ServiceBag")
local UpgradesConfig = require("UpgradesConfig")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local UpgradeServiceServer = {}

-- [ Types ] --
type ModuleData = {
    _ServiceBag: ServiceBag.ServiceBag,
    _DataServiceServer: typeof(require("DataServiceServer"))
}

export type Module = typeof(UpgradeServiceServer) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function UpgradeServiceServer.GetUpgradeLevel(self: Module, player: Player, upgradeName: string): number
    local Data = self._DataServiceServer:GetData(player)

    return Data.Upgrades[upgradeName]
end

function UpgradeServiceServer.PurchaseUpgrade(self: Module, player: Player, upgradeName: string)
    local UpgradeConfig = UpgradesConfig[upgradeName]
    local CurrencyName = UpgradeConfig.Currency
    local data = self._DataServiceServer:GetProfile(player).Data

    local CurrencyAmount = data.Currencies[CurrencyName]

    if not CurrencyAmount then
        return
    end

    if not data.Upgrades[upgradeName] then
        return
    end

    local UpgradePrice = UpgradeConfig.GetPrice(data.Upgrades[upgradeName])

    if CurrencyAmount < UpgradePrice then
        return
    end

    data.Currencies[CurrencyName] = CurrencyAmount - UpgradePrice
    data.Upgrades[upgradeName] += 1
end

function UpgradeServiceServer.Init(self: Module, serviceBag: ServiceBag.ServiceBag)
    if self._ServiceBag ~= nil then
        error("Service already initialized")
    end

    self._ServiceBag = assert(serviceBag, "No serviceBag")
    self._DataServiceServer = self._ServiceBag:GetService(require("DataServiceServer"))
end

function UpgradeServiceServer.Start(self: Module)
    
end

return UpgradeServiceServer :: Module