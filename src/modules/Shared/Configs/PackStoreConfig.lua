--[=[
    @class PacksStoreConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local PackStoreTypesShared = require("PackStoreTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local PacksStoreConfig = {}

-- [ Private Functions ] --
function PacksStoreConfig._Init(self: Module)
    self.SaleDuration = 30 * 60 -- seconds a sale stays purchasable after StartTime
    self.Categories = {"Normal", "Special"}
    self.LocalCategories = {
        Normal = {
            ["Super Pack"] = {
                PackName = "Super Pack",
                Stock = NumberRange.new(1, 2)
            }
        },
    }
    self.Prices = {
        Normal = {
            ["Super Pack"] = {
                Currency = "Coins",
                Amount = 100,
            },
            ["Mega Pack"] = {
                Currency = "Coins",
                Amount = 100,
            }
        },
        Special = {
            ["Super Pack"] = {
                Currency = "Coins",
                Amount = 100,
            },
            ["Mega Pack"] = {
                Currency = "Coins",
                Amount = 100,
            }
        }
    }
end

-- [ Public Functions ] --

-- [ Types ] --

type ModuleData = {
    SaleDuration: number,
    Categories: { PackStoreTypesShared.Category },
    LocalCategories: { 
        [PackStoreTypesShared.Category]: { 
            [string]: {
                PackName: string,
                Stock: NumberRange,
            }
        }
    },
    Prices: {
        [PackStoreTypesShared.Category]: { 
            [string]: {
                Currency: string,
                Amount: number,
            }
        }
    }
}

export type Module = typeof(PacksStoreConfig) & ModuleData

(PacksStoreConfig :: any):_Init()

return PacksStoreConfig :: Module