--[=[
    @class MerchantConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local _require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local MerchantConfig = {}

-- [ Private Functions ] --
function MerchantConfig._Init(self: Module)
    self.RefreshTime = 1000
    self.BuyItems = {
        ["Tomato"] = {
            Name = "Tomato",
            Stock = NumberRange.new(1, 4),
            Price = 100,
            Currency = "Coins",
            Chance = 100,
        }
    }
    self.SellItems = {
        ["Snow Blossom Fruit"] = {
            Name = "Snow Blossom Fruit",
            Price = 100,
            Currency = "Coins"
        }
    }
end

-- [ Public Functions ] --

-- [ Types ] --
type ModuleData = {
    RefreshTime: number,
    BuyItems: {
        [string]: {
            Name: string,
            Stock: NumberRange,
            Price: number,
            Currency: string,
            Chance: number,
        }
    },
    SellItems: {
        [string]: {
            Name: string,
            Price: number,
            Currency: string,
        }
    },
}

export type Module = typeof(MerchantConfig) & ModuleData

(MerchantConfig :: any):_Init()

return MerchantConfig :: Module