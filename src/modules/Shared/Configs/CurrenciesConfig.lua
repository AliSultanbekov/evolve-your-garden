--[=[
    @class CurrenciesConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local CurrenciesConfig = {}

-- [ Private Functions ] --
function CurrenciesConfig._Init(self: Module)
    self.Currencies = {
        ["Coins"] = {
            Name = "Coins",
            Rarity = "Common",
            Icon = "rbxassetid://137822539684508",
        },
        ["Gems"] = {
            Name = "Gems",
            Rarity = "Common",
            Icon = "rbxassetid://83087975713139",
        }
    }
end

-- [ Public Functions ] --

-- [ Types ] --
type CurrencyEntry = {
    Name: string,
    Rarity: string,
    Icon: string,
}

type ModuleData = {
    Currencies: { [string]: CurrencyEntry },
}

export type Module = typeof(CurrenciesConfig) & ModuleData

(CurrenciesConfig :: any):_Init()

return CurrenciesConfig :: Module