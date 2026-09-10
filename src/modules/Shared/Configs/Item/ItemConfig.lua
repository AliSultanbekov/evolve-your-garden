--[=[
    @class ItemConfig
]=]

-- [ Roblox Services ] --

-- [ Require ] --
local require = require(script.Parent.loader).load(script) :: typeof(require)

-- [ Imports ] --
local ItemTypes = require("ItemTypes")
local PlantsConfig = require("PlantsConfig")
local MaterialsConfig = require("MaterialsConfig")
local CurrenciesConfig = require("CurrenciesConfig")
local PacksConfig = require("PacksConfig")
local Table = require("Table")

-- [ Constants ] --

-- [ Variables ] --

-- [ Module Table ] --
local ItemConfig = {
    CategoryToStorageMode = {
        ["Plant"] = "Unique",
        ["Material"] = "Stackable",
        ["Pack"] = "Stackable",
        ["Currency"] = "Stackable",
    },
    RarityLayoutOrder = {
        ["Common"] = 1,
        ["Uncommon"] = 2,
        ["Rare"] = 3,
        ["Epic"] = 4,
        ["Legendary"] = 5,
        ["Mythic"] = 6,
        ["Celestial"] = 7,
    },
    Categories = {"Plant", "Material", "Pack", "Currency"},
    MaxAmount = 100000
}

-- [ Types ] --
type ModuleData = {
    CategoryToStorageMode: {
        [ItemTypes.Category]: ItemTypes.StorageMode
    },
    Categories: { ItemTypes.Category },
    MaxAmount: number,
}

export type Module = typeof(ItemConfig) & ModuleData

-- [ Private Functions ] --

-- [ Public Functions ] --
function ItemConfig.GetCategory(self: Module, itemName: string): ItemTypes.Category
    if PlantsConfig.Plants[itemName] then
        return "Plant"
    elseif MaterialsConfig.Materials[itemName] then
        return "Material"
    elseif PacksConfig.Packs[itemName] then
        return "Pack"
    elseif CurrenciesConfig.Currencies[itemName] then
        return "Currency"
    else
        error("No category found for item: " .. tostring(itemName))
    end
end

function ItemConfig.GetIcon(self: Module, itemName: string, itemCategory: ItemTypes.Category?): string
    local Category = itemCategory or self:GetCategory(itemName)

    if Category == "Plant" then
        return PlantsConfig.Plants[itemName].Icon
    elseif Category == "Material" then
        return MaterialsConfig.Materials[itemName].Icon
    elseif Category == "Pack" then
        return PacksConfig.Packs[itemName].Icon
    elseif Category == "Currency" then
        return CurrenciesConfig.Currencies[itemName].Icon
    end

    error("No icon found for item: " .. tostring(itemName) .. " (" .. tostring(Category) .. ")")
end

function ItemConfig.GetRarity(self: Module, itemName: string, itemCategory: ItemTypes.Category?): ItemTypes.Rarity
    local Category = itemCategory or self:GetCategory(itemName)

    if Category == "Plant" then
        return PlantsConfig.Plants[itemName].Rarity
    elseif Category == "Material" then
        return MaterialsConfig.Materials[itemName].Rarity
    elseif Category == "Pack" then
        return PacksConfig.Packs[itemName].Rarity
    elseif Category == "Currency" then
        return CurrenciesConfig.Currencies[itemName].Rarity
    end

    error("No rarity found for item: " .. tostring(itemName) .. " (" .. tostring(Category) .. ")")
end

function ItemConfig.GetAllItemsConfigs(self: Module)
    local ItemsConfigs = {}

    for _, category in pairs(self.Categories) do
        if category == "Plant" then
            ItemsConfigs = Table.merge(ItemsConfigs, PlantsConfig.Plants)
        elseif category == "Material" then
            ItemsConfigs = Table.merge(ItemsConfigs, MaterialsConfig.Materials)
        elseif category == "Pack" then
            ItemsConfigs = Table.merge(ItemsConfigs, PacksConfig.Packs)
        elseif category == "Currency" then
            ItemsConfigs = Table.merge(ItemsConfigs, CurrenciesConfig.Currencies)
        end
    end

    return ItemsConfigs
end

return ItemConfig :: Module
