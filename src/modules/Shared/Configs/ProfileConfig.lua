--[=[
    @class ProfileConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local GardenTypesShared = require("GardenTypesShared")
local PackStoreTypesShared = require("PackStoreTypesShared")
local MerchantTypesShared = require("MerchantTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ProfileConfig = {
    Template = {
        Upgrades = {
            Garden = 1
        },
        Inventory = {
            ["Coins"] = {
                Id = "Coins",
                Name = "Coins",
                Category = "Currency" :: "Currency",
                Amount = 5000,
            },
            ["Gems"] = {
                Id = "Gems",
                Name = "Gems",
                Category = "Currency" :: "Currency",
                Amount = 5000,
            },
        },
        Garden = {
            Slots = {},
        },
        PackStore = {
            SaleId = "",
            Packs = {}
        },
        Merchant = {
            
        }
    },
    Leaderstats = {}
} :: { Template: ProfileTemplate, Leaderstats: { [string]: string }}

-- [ Types ] --

export type ProfileTemplate = {
    Upgrades: {
        Garden: number
    },
    Inventory: {
        [ItemTypes.ItemId]: ItemTypes.Item
    },
    Garden: {
        Slots: GardenTypesShared.Slots
    },
    PackStore: PackStoreTypesShared.PackStore,
    Merchant: MerchantTypesShared.Merchant
}

return ProfileConfig