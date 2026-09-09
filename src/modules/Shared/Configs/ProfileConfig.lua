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
local EncyclopediaTypesShared = require("EncyclopediaTypesShared")
local StatsTypesShared = require("StatsTypesShared")
local QuestsTypesShared = require("QuestsTypesShared")

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
            
        },
        Encyclopedia = {
            DiscoveredItems = {},
            CompletedQuests = {},
        },
        Stats = {
            PlayTime = 0
        },
        Quests = {
            Active = {},
            Completed = {},
            Burnt = {},
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
    Merchant: MerchantTypesShared.Merchant,
    Encyclopedia: EncyclopediaTypesShared.Encyclopedia,
    Stats: StatsTypesShared.Stats,
    Quests: QuestsTypesShared.QuestsData
}

return ProfileConfig