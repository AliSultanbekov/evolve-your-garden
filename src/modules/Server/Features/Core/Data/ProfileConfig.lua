--[=[
    @class ProfileConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local GardenTypesShared = require("GardenTypesShared")
local PackStoreTypesShared = require("PackStoreTypesShared")
local MerchantTypesShared = require("MerchantTypesShared")
local EncyclopediaTypesShared = require("EncyclopediaTypesShared")
local StatsTypesShared = require("StatsTypesShared")
local QuestsTypesShared = require("QuestsTypesShared")
local ToolbarTypesShared = require("ToolbarTypesShared")
local InventoryTypesShared = require("InventoryTypesShared")
local UpgradesTypesShared = require("UpgradesTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ProfileConfig = {
    Template = {
        Upgrades = {},
        Inventory = {},
        Garden = {},
        PackStore = {},
        Merchant = {},
        Encyclopedia = {},
        Stats = {},
        Quests = {},
        Toolbar = {},
    },
    Leaderstats = {}
} :: { Template: ProfileTemplate, Leaderstats: { [string]: string }}

-- [ Types ] --

export type ProfileTemplate = {
    Upgrades: UpgradesTypesShared.UpgradesData,
    Inventory: InventoryTypesShared.InventoryData,
    Garden: GardenTypesShared.GardenData,
    PackStore: PackStoreTypesShared.PackStore,
    Merchant: MerchantTypesShared.Merchant,
    Encyclopedia: EncyclopediaTypesShared.Encyclopedia,
    Stats: StatsTypesShared.Stats,
    Quests: QuestsTypesShared.QuestsData,
    Toolbar: ToolbarTypesShared.Slots,
}

return ProfileConfig