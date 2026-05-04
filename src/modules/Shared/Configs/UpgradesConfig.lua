--[=[
    @class UpgradeConfig
]=]

-- [ Roblox Services ] --

-- [ Imports ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local UpgradeConfig = {
    ["Garden"] = {
        Currency = "Coins",
        MaxLevel = 10,
        GetPrice = function(level: number): number
            return 100 + (level * 50)
        end
    }
} :: {
    [string]: {
        Currency: string,
        MaxLevel: number,
        GetPrice: (level: number) -> number
    }
}

-- [ Types ] --
type ModuleData = {}

export type Module = typeof(UpgradeConfig) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --

return UpgradeConfig :: Module