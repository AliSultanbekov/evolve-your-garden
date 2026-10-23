--[=[
    @class UpgradesConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local UpgradesConfig = {}

-- [ Private Functions ] --
function UpgradesConfig._Init(self: Module)
    self.Upgrades = {
        ["Garden"] = {
            Currency = "Coins",
            MaxLevel = 10,
            GetPrice = function(level: number): number
                return 100 + (level * 50)
            end
        }
    }
end

-- [ Public Functions ] --

-- [ Types ] --
type UpgradeEntry = {
    Currency: string,
    MaxLevel: number,
    GetPrice: (level: number) -> number,
}

type ModuleData = {
    Upgrades: { [string]: UpgradeEntry },
}

export type Module = typeof(UpgradesConfig) & ModuleData

(UpgradesConfig :: any):_Init()

return UpgradesConfig :: Module
