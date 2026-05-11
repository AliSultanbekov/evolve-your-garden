--[=[
    @class ProfileConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local GardenTypesShared = require("GardenTypesShared")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ProfileConfig = {
    Template = {
        Upgrades = {
            Garden = 1
        },
        Currencies = {
            Coins = 0,
            Gems = 0,
        },
        Inventory = {},
        Garden = {
            Slots = {},
        },
    },
    Leaderstats = {["Currencies/Coins"] = "IntValue"}
} :: { Template: ProfileTemplate, Leaderstats: { [string]: string }}

-- [ Types ] --

export type ProfileTemplate = {
    Upgrades: {
        Garden: number
    },
    Currencies: {
        Coins: number,
        Gems: number,
    },
    Inventory: {
        [ItemTypes.ItemId]: ItemTypes.Item
    },
    Garden: {
        Slots: {
            [GardenTypesShared.SlotId]: GardenTypesShared.SlotData
        }
    }
}

return ProfileConfig